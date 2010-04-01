class FreightTrain::Responder < ActionController::Responder
  
  
  # methods in FreightTrain::Core
  delegate :refresh_on_create, :refresh_on_update, :remove_deleted, :show_error, :show_errors_for, :show_exception_for,
           :to => :controller

  
  def to_html
    if request.xhr?
      create  if post?
      update  if put?
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
    # nb! should require Rails 2.3.4 or greater!
    destroyed = resource.respond_to?(:destroyed?) ? resource.destroyed? : !resource.class.find_by_id(resource.id)
    puts "DESTROYED: #{destroyed}"
    begin
      if destroyed
        remove_deleted resource
      else
        show_error "Unable to destroy #{resource}"
      end
    rescue
      show_error "#{$!}"
    end
  end


end