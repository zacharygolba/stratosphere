ActionController::Base.class_eval do
  before_action do
    if params[:stratosphere_submitted]
      if stratosphere_model
        @upload_params = { 
          file_name: params[:file_name],
          content_type: params[:content_type]
        }
        render_stratosphere_upload_url
      end
    end
  end
  
  protected
    def stratosphere_model
      model = self.class.to_s.gsub!('Controller', '').singularize.safe_constantize
      model && model.respond_to?(:has_attachment) ? model : nil
    end
  
    def stratosphere_upload_url
      o = stratosphere_model.find_by(id: params[:id])
      o ? o.send(:"#{stratosphere_model.attachment_name}").presigned_upload(@upload_params) : nil
    end

    def render_stratosphere_upload_url
      render json: { url: stratosphere_upload_url }
    end
end