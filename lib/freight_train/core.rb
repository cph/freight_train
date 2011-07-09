module FreightTrain
  module Core
    include FreightTrain::Helpers::FormattingHelper
    include FreightTrain::Helpers::RowHelper
    
    # !todo: refactor these names?
    # !todo: refactor 'show_error_for' using LailExtensions' flash updater?
    
    
    
    def refresh_on_create(record, options={})
      options.merge!(params[:ft] || {})
      
      options       = options.with_indifferent_access
      model_name    = record.class.name
      partial_name  = options[:partial] || record.class.name.underscore
      content       = javascript_object_for(render_to_string(:partial => partial_name, :object => record))
      
      render :inline => "FT.#{model_name}.addRow(#{content});",
             :content_type => "application/javascript"
    end
    
    
    
    def refresh_on_update(record, options={})
      options.merge!(params[:ft] || {})
      
      # this is kind of a clunky way of solving this problem; but I want row_for to know whether
      # it is creating a row or updating a row (whether it should write the TR tags or not).
      @update_row = true
      
      options       = options.with_indifferent_access
      id            = idof(record)
      model_name    = record.class.name
      partial_name  = options[:partial] || record.class.name.underscore
      content       = javascript_object_for(render_to_string(:partial => partial_name, :object => record))
      
      render :inline => "FT.#{model_name}.updateRow('#{id}', #{content});",
             :content_type => "application/javascript"
    end
    
    
    
    def remove_deleted(record)
      id         = idof(record)
      model_name = record.class.name
      render :inline => "FT.#{model_name}.deleteRow('#{id}')",
             :content_type => "application/javascript"
    end
    
    
    
    def show_error(*args)
      options = args.extract_options!.with_indifferent_access
      message = args.first
      id      = options[:error_id] || "flash_error"
      
      content = <<-JS
      var e = FT.$.find_by_id('#{id}');
      if(e) {
        FT.$.replace(e, #{message.to_json});
        FT.$.show(e);
        #(!!options[:alert]) && alert(#{options[:alert].to_json});
      }
      JS
    end
    
    
    
    def show_errors_for(record, options={})
      show_error(format_errors(record), options)
    end
    
    
    
  private
    
    
    
    def javascript_object_for(object)
      ::ActiveSupport::JSON.encode(object)
    end
    
    
    
  end
end