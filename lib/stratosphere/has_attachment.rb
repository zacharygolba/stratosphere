module Stratosphere
  module HasAttachment
    extend ActiveSupport::Concern

    module ClassMethods
      def has_attachment(options={})
        cattr_accessor :crop_params, :attachment_name, :attachment_styles, :attachment_type, :path_to_default

        self.attachment_name   = options[:name]
        self.attachment_styles = options[:styles]
        self.attachment_type   = options[:type]
        self.path_to_default   = options[:default]

        define_method "#{attachment_name}" do
          Stratosphere::Attachment.new(self)
        end

        self.send(:before_save) do
          if self.send(:"#{attachment_name}_file_changed?")
            attr = self.send(:"#{attachment_name}_file")
            attachment  = Stratosphere::Attachment.new(self)

            if attr.class == String && attr =~ /\A\S+\z/
              self[:"#{attachment_name}_file"] = nil
              attachment.destroy!
            elsif attr.class == NilClass
              attachment.destroy!
            end
          end
        end

        self.send(:before_destroy) do
          Stratosphere::Attachment.new(self).destroy!
        end
      end
    end

  end
end
ActiveRecord::Base.send :include, Stratosphere::HasAttachment