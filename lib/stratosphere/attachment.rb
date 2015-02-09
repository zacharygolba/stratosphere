module Stratosphere
  class Attachment
    attr_accessor :base_path, :config, :file_name, :name, :owner

    def initialize(owner, name, options={})
      @config      = Stratosphere.config
      @name        = name
      @owner       = owner
      @file_name   = @owner["#{@name}_file"]
      
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

    def url
      "#{config.domain}/#{base_path}/#{file_name}" if file_name
    end

    def presigned_upload(options)
      Stratosphere::AWS::S3.presigned_upload(options.merge(key: "#{base_path}/#{options[:file_name]}"))
    end

    def destroy!
      Stratosphere::AWS::S3.delete_objects(base_path)
    end
  end
end