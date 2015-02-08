module Stratosphere
  class Attachment
    attr_accessor :base_path, :config, :default, :file_name, :owner, :styles

    def initialize(owner)
      self.config    = Stratosphere.config
      self.owner     = owner
      self.file_name = owner["#{owner.class.attachment_name}_file"] if owner.class.attachment_name
      self.default   = owner.class.path_to_default
      self.styles    = []
      plural_attr    = owner.class.attachment_name.to_s.pluralize
      plural_model   = owner.class.to_s.downcase.pluralize
      
      if config.dir_prefix
        prefix = config.dir_prefix[-1, 1] == '/' ? config.dir_prefix.slice(0, -1): config.dir_prefix
        self.base_path = "#{prefix}/#{plural_model}/#{plural_attr}/#{owner.id}"
      else
        self.base_path = "#{plural_model}/#{plural_attr}/#{owner.id}"
      end
      
      if file_name
        owner.class.attachment_styles.each { |style| styles.push Stratosphere::Style.new( style.merge(file_name: file_name) ) }
      end
    end

    def url(style_name=:original)
      url = "#{config.domain}/#{default}"
      if file_name
        url = "#{config.domain}/#{base_path}/#{style_name.to_s}/#{file_name}"
        unless style_name == :original
          style = styles.count > 0 ? self.styles.select { |style| style.name == style_name }.first : nil
          url.gsub!(file_name, style.file_name) unless style.nil?
        end
      end
      url
    end

    def presigned_upload(options)
      Stratosphere::AWS::S3.presigned_upload(options.merge(key: "#{base_path}/original/#{file_name}"))
    end

    def crop(x, y, w, h)
      io      = open(url)
      file    = Magick::Image.from_blob(io.read).first.crop(x.to_i, y.to_i, w.to_i, h.to_i)
      threads = []
      io.close
      self.styles.each do |style|
        if style.dimensions
          t = Thread.new  do
            k = "#{base_path}/#{style.name}/#{file_name}"
            r = file.resize(style.dimensions[0], style.dimensions[1])
            Stratosphere::AWS::S3.upload({ key: k, content_type: 'image/jpeg', body: r.to_blob })
          end
          threads.push(t)
        end
      end
      threads.each(&:join)
    end

    def encode
      options = {
          pipeline_id: config.aws[:transcoder][:pipeline],
          input: {
              key: "#{base_path}/original/#{file_name}",
              frame_rate: 'auto',
              resolution: 'auto',
              aspect_ratio: 'auto',
              interlaced: 'auto',
              container: 'auto'
          },
          outputs: []
      }
      styles.each_with_index do |s, i|
        unless s.format.nil? || s.name == :thumb
          k = "#{base_path}/#{s.format.to_s}/#{file_name.gsub("#{File.extname(file_name)}", '')}.#{s.format.to_s}"
          p = config.aws[:transcoder][:formats][s.format]
          t = i == 1 ? "#{base_path}/thumb/#{file_name.gsub("#{File.extname(file_name)}", '')}-{count}" : ''
          options[:outputs].push({ key: k, preset_id: p, thumbnail_pattern: t, rotate: '0' })
        end
      end
      Stratosphere::AWS::ElasticTranscoder.create_job(options)
    end

    def destroy!
      Stratosphere::AWS::S3.delete_objects(base_path)
    end
  end
end