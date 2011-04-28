
module FreightTrain
  module Core
    include FreightTrain::Helpers::FormattingHelper
    
    # TODO: remove :originating_controller - check
    # TODO: refactor these names?
    # TODO: refactor 'show_error_for' using LailExtensions' flash updater?
    
    
    
    def refresh_on_create(refresh, record, options={}, &block)
      options.merge!(params[:ft] || {})
      
      # this causes an error when performed inside of render block (is it performed in context of view instead of controller?)
      unless refresh == :single
        options[:find] = get_finder(options[:find] || {})
      end
      
      render :update do |page|
        page.safe_hide "flash_error"
        
        case refresh
        when :single
          page.add_record record, options
          page.fire(:create, idof(record))
        else
          page.refresh_records record.class, options
        end
        
        yield(page) if block_given?
      end
    end
    
    
    
    def refresh_on_update(refresh, record, options={}, &block)
      options.merge!(params[:ft] || {})
      
      render :update do |page|
        page.safe_hide "flash_error"
        # page.call "FT.InlineEditor.close"
        
        case refresh
        when :single
          # this is kind of a clunky way of solving this problem; but I want row_for to know whether
          # it is creating a row or updating a row (whether it should write the TR tags or not).
          @update_row = true
          page.refresh_record record, options
          page.fire(:update, idof(record))
        else
          options[:find] = get_finder(options[:find] || {})
          page.refresh_records record.class, options
        end
        
        yield(page) if block_given?
      end
    end
    
    
    
    def remove_deleted(record, &block)
      render :update do |page|
        page.fire(:destroy, idof(record))
        yield(page) if block_given?
      end
    end
    
    
    
    def show_error(*args)
      options = args.extract_options!
      message = args.first    
      render(:update, :status => 400) do |page|
        page.show_error(message, options) if message
        page.alert options[:alert] if options.key?(:alert)
        yield(page) if block_given?
      end
    end
    
    
    
    def show_errors_for(record, options={}, &block)
      show_error(format_errors(record), options, &block)
    end
    
    
    
    def show_exception_for(record, options={}, &block)
      message = format_exception_for(record, options.merge(:action => action_name))
      show_error(message, options, &block)
    end
    
    
    
  end
end