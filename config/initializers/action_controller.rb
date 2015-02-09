ActionController::Base.class_eval do
  protected
    def stratosphere_model
      model = self.class.to_s.gsub!('Controller', '').singularize.safe_constantize
      model && model.respond_to?(:has_attachment) ? model : nil
    end
  
    def stratosphere_upload_url
      if stratosphere_model
        o = stratosphere_model.find_by(id: params[:id])
        p = params.to_h.keep_if { |key| [:content_type, :content_length, :file_name].include?(key) }
        o && p.count == 3 ? o[stratosphere_model.attachment_name].presigned_upload(p) : nil
      end
    end
end