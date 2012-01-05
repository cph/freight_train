module RequestExtension
  
  def freight_train?
    (parameters[:freight_train] == 'true')
  end
  
end

ActionController::Request.send(:include, RequestExtension) if defined?(ActionController::Request)
ActionDispatch::Request.send(:include, RequestExtension) if defined?(ActionDispatch::Request)  
