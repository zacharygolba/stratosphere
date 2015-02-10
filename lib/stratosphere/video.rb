module Stratosphere
  class Video < Attachment
    attr_accessor :default, :styles

    def initialize(owner, name, options={})
      super
      @type    = :video
      @styles  = []
      @default = options[:default]
      if @file_name && options[:styles] && options[:styles].count > 0
        options[:styles].each { |style| @styles.push Stratosphere::Style.new( style.merge(file_name: @file_name) ) }
      end
    end

    def url(style_name=:original)
      url = default ? "#{config.domain}/#{default}" : nil
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
      options.merge!(key: "#{base_path}/original/#{options[:file_name]}")
      options.delete :file_name
      Stratosphere.file_store.presigned_upload options
    end
    
    def encode
      if styles.count > 0
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
    end
  end
end