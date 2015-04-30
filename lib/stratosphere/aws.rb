module Stratosphere
  module AWS
    class S3
      attr_accessor :credentials, :resource, :region, :bucket_name, :presigner
      
      def initialize
        key                      = Stratosphere.config.aws[:access_key]
        secret                   = Stratosphere.config.aws[:secret]
        @region                  = Stratosphere.config.aws[:region]
        @bucket_name             = Stratosphere.config.aws[:s3_bucket]
        @credentials             = Aws::Credentials.new(key, secret)
        @resource                = Aws::S3::Resource.new(credentials: @credentials, region: @region)
        @presigner               = Aws::S3::Presigner.new(region: @region)
        Aws.config[:region]      = @region
        Aws.config[:credentials] = @credentials
      end
      
      def bucket
        resource.bucket bucket_name
      end

      def delete_objects(prefix)
        threads = []
        bucket.objects(prefix: prefix).limit(50).each { |object| threads.push Thread.new { object.delete if object } }
        threads.each(&:join)
      end

      def upload(options={})
        bucket.put_object(options)
      end

      def presigned_upload(options={})
        params = options.keep_if { |k,v| [:key, :content_type, :content_length, :acl].include? k }.merge!(bucket: bucket_name)
        presigner.presigned_url(:put_object, params)
      end
    end

    class ElasticTranscoder
      def self.encoder
        key    = Stratosphere.config.aws[:access_key]
        secret = Stratosphere.config.aws[:secret]
        Aws::ElasticTranscoder::Client.new(credentials: Aws::Credentials.new(key, secret), region: Stratosphere.config.aws[:region])
      end

      def self.create_job(params)
        encoder.create_job(params)
      end
    end
  end
end