module Stratosphere
  module Generators
    class AttachmentGenerator < ::Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)

      desc "Generate a migration to support a stratosphere attachment on your model. The #{"\033[32mNAME\033[0m"} " <<
           "argument represents the model you would like to add an attachment to and the #{"\033[36mATTACHMENT_NAME\033[0m"} " <<
           "represents the name of the attachment. i.e. rails generate attachment #{"\033[32muser\033[0m"} #{"\033[36mavatar\033[0m"}."

      argument :model_name, required: true, type: :string
      argument :attachment_name, required: true, type: :string, desc: 'A name for the attachment you would like to add.'

      def create_migration
        generate 'migration', "AddAttachmentTo#{model_name.classify.pluralize} #{attachment_name}_file:string #{attachment_name}_content_type:string #{attachment_name}_content_length:int8"
      end
    end
  end
end