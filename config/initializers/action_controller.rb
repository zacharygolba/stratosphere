ActionController::Base.class_eval do
  before_action do
    if params[:stratosphere_submitted]
      if stratosphere_model
        case action_name
          when 'edit'
            @upload_params = {
              file_name: params[:file_name],
              content_type: params[:content_type],
              content_length: params[:content_length]
            }
            render_stratosphere_upload_url
          when 'update'
            if params[:crop_params]
              @crop_params = params[:crop_params]
              render_attachment_crop
            else
              @update_params  = {}
              attachment_name = stratosphere_model.attachment_name
              %W(#{attachment_name}_file #{attachment_name}_content_type #{attachment_name}_content_length).each do |param|
                @update_params[:"#{param}"] = (param == "#{attachment_name}_content_length") ? params[:"#{param}"].to_i : params[:"#{param}"]
              end
              render_attachment_update
            end
          else
            nil
        end
      end
    end
  end
  
  protected
    def stratosphere_model
      model = self.class.to_s.gsub!('Controller', '').singularize.safe_constantize
      model && model.respond_to?(:has_attachment) ? model : nil
    end
  
    def stratosphere_upload_url
      stratosphere_model.find(params[:id]).send(:"#{stratosphere_model.attachment_name}").presigned_upload(@upload_params)
    end

    def render_stratosphere_upload_url
      render json: { url: stratosphere_upload_url }
    end
  
    def render_attachment_update
      render json: stratosphere_model.find(params[:id]).update!(@update_params)
    end
  
    def render_attachment_crop
      model      = stratosphere_model.find(params[:id])
      attachment = model.send(:"#{stratosphere_model.attachment_name}")
      attachment.crop(@crop_params)
      render json: attachment
    end
end