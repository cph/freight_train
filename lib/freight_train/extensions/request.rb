class ActionController::Request
  
  
  
  def freight_train?
    (parameters[:freight_train] == 'true')
  end
  
  
  
end