module Stratosphere
  module HasAttachment
    extend ActiveSupport::Concern

    module ClassMethods
      def has_attachment(name, options={})
        cattr_accessor :attachment_name, :attachment_type
        
        self.attachment_name = name
        self.attachment_type = options[:type]
        
        define_method "#{name}" do
          case options[:type]
            when :image
              Stratosphere::Image.new(self, name, options)
            when :video
              Stratosphere::Video.new(self, name, options)
            else
              Stratosphere::Attachment.new(self, name, options)
          end
        end

        send(:before_save) do
          if send(:"#{name}_file_changed?")
            attr = self[:"#{name}_file"]
            
            if [:image, :video].include? options[:type]
              if options[:type] == :image
                @attachment = Stratosphere::Image.new(self, name, options)
              elsif options[:type] == :video
                @attachment = Stratosphere::Video.new(self, name, options)
              end
            else
              @attachment = Stratosphere::Attachment.new(self, name, options)
            end

            if attr.class == String && attr =~ /\A\S+\z/
              self[:"#{name}_file"] = nil
              @attachment.destroy!
            elsif attr.class == NilClass
              @attachment.destroy!
            end
          end
        end

        self.send(:before_destroy) do
          case options[:type]
            when :image
              Stratosphere::Image.new(self, name, options).destroy!
            when :video
              Stratosphere::Video.new(self, name, options).destroy!
            else
              Stratosphere::Attachment.new(self, name, options).destroy!
          end
        end
      end
    end
    
  end
end
ActiveRecord::Base.send :include, Stratosphere::HasAttachment