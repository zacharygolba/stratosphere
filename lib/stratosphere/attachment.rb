module Stratosphere
  class Attachment
    attr_accessor :base_path, :config, :file_name, :name, :size, :mime_type, :type, :owner, :file_store

    def self.create_config(options={})
      config = Stratosphere.config.to_hash

      unless options.nil?
        unless options[:aws].nil?
          options[:aws] = config[:aws].merge(options[:aws])
        end
        config.merge!(options)
      end
      Stratosphere::Config.new(config)
    end

    def initialize(owner, name, options={})
      @config     = self.class.create_config(options[:config])
      @name       = name
      @owner      = owner
      @file_name  = @owner["#{@name}_file"]
      @file_size  = @owner["#{@name}_content_length"]
      @mime_type  = @owner["#{@name}_content_type"]
      @type       = :attachment
      @file_store = Stratosphere::AWS::S3.new(@config)
      set_base_path
    end

    def set_base_path
      plural_attr  = name.to_s.pluralize
      plural_model = owner.class.to_s.downcase.pluralize

      if config.dir_prefix
        prefix     = config.dir_prefix[-1, 1] == '/' ? config.dir_prefix.slice(0, -1) : config.dir_prefix
        @base_path = "#{prefix}/#{plural_model}/#{plural_attr}/#{owner.id}"
      else
        @base_path = "#{plural_model}/#{plural_attr}/#{owner.id}"
      end
    end

    def exists?
      !file_name.nil?
    end

    def has_default?
      false
    end

    def url
      "#{config.domain}/#{base_path}/#{file_name}" if file_name
    end

    def presigned_upload(options)
      options.merge!(key: "#{base_path}/#{options[:file_name]}")
      options.delete :file_name
      file_store.presigned_upload options
    end

    def destroy!
      file_store.delete_objects base_path
    end
  end
end
