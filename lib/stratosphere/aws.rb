module Stratosphere
  module AWS
    class S3
      def self.bucket
        key         = Stratosphere.config.aws[:access_key] 
        secret      = Stratosphere.config.aws[:secret]
        region      = Stratosphere.config.aws[:region]
        resource    = Aws::S3::Resource.new(credentials: Aws::Credentials.new(key, secret), region: region)
        bucket_name = Stratosphere.config.aws[:s3_bucket]
        resource.bucket(bucket_name)
      end

      def self.delete_objects(prefix)
        threads = []
        bucket.objects(prefix: prefix).limit(50).each { |object| threads.push Thread.new { object.delete if object } }
        threads.each(&:join)
      end

      def self.upload(options={})
        self.bucket.put_object(options)
      end

      def self.presigned_upload(options={})
        Aws::S3::Presigner.new.presigned_url(:put_object, {
            bucket: self.bucket.name,
            key: options[:key],
            content_type: options[:content_type],
            content_length: options[:content_length]
        })
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