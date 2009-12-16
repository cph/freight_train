class FreightTrain::Responder < ActionController::Responder
  
  
  # methods in FreightTrain::Core
  delegate :refresh_on_create, :refresh_on_update, :remove_deleted, :show_errors_for, :show_exception_for,
           :to => :controller

  
  def to_html
    if request.xhr?
      create if post?
      update if put?
      destroy if delete?
    end
  end
  
  
protected

  
  def create
    if has_errors?
      show_errors_for resource #, options
    else
      refresh_on_create :single, resource #, options
    end
  end
  
  def update
    if has_errors?
      show_errors_for resource #, options
    else
      refresh_on_update :single, resource #, options
    end
  end
  
  def destroy
    if resource.destroyed?
      remove_deleted resource
    else
    end
  end


end