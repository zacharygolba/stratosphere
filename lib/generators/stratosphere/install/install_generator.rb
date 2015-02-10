module Stratosphere
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      attr_accessor :key, :secret, :bucket
      
      source_root File.expand_path('../../../../../', __FILE__)

      desc 'Add stratosphere views for easy attachment uploads via AJAX.'
      
      def set_options
        STDOUT.flush
        
        print 'What is your AWS Access Key? '
        @key = gets.chomp
        
        print 'What is your AWS Secret? '
        @secret = gets.chomp
        
        print 'What is your S3 Bucket name? '
        @bucket = gets.chomp
      end
      
      def create_initializer
        template 'lib/generators/stratosphere/install/templates/stratosphere.rb.erb', 'config/initializers/stratosphere.rb'
      end

      def create_views
        copy_file 'app/views/_attachment_field.html.erb', 'app/views/stratosphere/_attachment_field.html.erb'
        copy_file 'app/views/_attachment_uploader.html.erb', 'app/views/stratosphere/_attachment_uploader.html.erb'
      end
    end
  end
end