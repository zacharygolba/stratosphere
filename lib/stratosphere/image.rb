require 'open-uri'
require 'rmagick'

module Stratosphere
  class Image < Attachment
    attr_accessor :default, :styles, :crop_params

    def initialize(owner, name, options={})
      super
      @type    = :image
      @styles  = []
      @default = options[:default]
      if @file_name && options[:styles] && options[:styles].count > 0
        options[:styles].each { |style| @styles.push Stratosphere::Style.new( style.merge(file_name: @file_name) ) }
      end
    end
    
    def has_default?
      !default.nil?
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
      file_store.presigned_upload options
    end
    
    def crop(x, y, w, h)
      if styles.count > 0
        begin
          io = open(url)
          file = Magick::Image.from_blob(io.read).first.crop(x.to_i, y.to_i, w.to_i, h.to_i)
          threads = []
          io.close
          styles.each do |style|
            if style.dimensions
              t = Thread.new do
                k = "#{base_path}/#{style.name}/#{file_name}"
                r = file.resize(style.dimensions[0], style.dimensions[1])
                Stratosphere.file_store.upload(key: k, content_type: 'image/jpeg', body: r.to_blob)
              end
              threads.push(t)
            end
          end
          threads.each(&:join)
        rescue OpenURI::HTTPError => e
          puts "Error: Original image not found at '#{url}'"
          puts e
        end
      end
    end
  end
end