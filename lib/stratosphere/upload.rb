module Stratosphere
  class Upload
    def initialize(file, options={})
      case Stratosphere.config.cloud
        when :aws
          upload_to_s3 file
        else
          nil
      end
    end
    
    def upload_to_s3(file)
      puts file
    end
  end
end