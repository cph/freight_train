module FreightTrain::Core
  include FreightTrain::Helpers::FormattingHelper


  def show_errors_for( record, options={}, &block )
    render :update do |page|
      page.show_error format_errors( record ), options
      page.alert options[:alert] if options.key?(:alert)
    end
  end 


  def show_exception_for( record, options={}, &block )
    render :update do |page|
      page.show_error format_exception_for(record, options.merge(:action => @current_action)), options
      page.alert options[:alert] if options.key?(:alert)
 
      if block_given?
        yield(page)
      end
    end
  end


  def refresh_on_create( refresh, record, options={}, &block )
    options[:originating_controller] = params[:originating_controller]
 
    # this causes an error when performed inside of render block (is it performed in context of view instead of controller?)
    unless refresh == :single
      options[:find] = get_finder(options[:find] || {})
    end
 
    render :update do |page|
      page.hide "flash_error"
 
      case refresh
      when :single
        page.add_record record, options
      else
        page.refresh_records record.class, options
      end
 
      page.call "FT.highlight", idof(record)
      page.call "FT.on_created"
 
      if block_given?
        yield(page)
      end
    end
  end


  def refresh_on_update( refresh, record, options={}, &block )
    options[:originating_controller] = params[:originating_controller]

    render :update do |page|
      page.hide "flash_error"
      page.call "InlineEditor.close"
 
      case refresh
      when :single
        # this is kind of a clunky way of solving this problem; but I want row_for to know whether
        # it is creating a row or updating a row (whether it should write the TR tags or not).
        @update_row = true
        page.refresh_record record, options
      else
        options[:find] = get_finder(options[:find] || {})
        page.refresh_records record.class, options
      end
 
      page.call "FT.highlight", idof(record)
 
      if block_given?
        yield(page)
      end
    end
  end


  def remove_deleted( record, &block )
    render :update do |page|
      page.call "FT.delete_record", idof(record)
 
      if block_given?
        yield(page)
      end
    end
  end
  

protected


  def responder
    FreightTrain::Responder
  end    
  
  
private


  def get_finder( finder_hash )
    finder_hash.is_a?(Symbol) ? send(finder_hash) : finder_hash
  end


end