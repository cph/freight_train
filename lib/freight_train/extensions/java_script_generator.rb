class ActionView::Helpers::PrototypeHelper::JavaScriptGenerator
  
  
  
  def refresh( mode, record, *args )
    case mode
    when :single
      refresh_record record, *args
    else
      refresh_records record.class, *args
    end
  end
  
  
  
  def fire(event, id)
    @lines << "FT.$.fire(FT.$.find_by_id('#{id}'), 'ft:#{event}');"
  end
  
  
  
  def safe_hide(*ids)
    ids.each do |id|
      @lines << "FT.$.hide(FT.$.find_by_id('#{id}'));"
    end
  end
  
  
  
  def add_record(record, *args)
    options       = args.extract_options!.with_indifferent_access
    model_name    = record.class.name
    partial_name  = options[:partial] || record.class.name.underscore
    content       = javascript_object_for(render(:partial => partial_name, :object => record))
    @lines << "FT.#{model_name}.addRow(#{content});"
  end
  
  
  
  def refresh_record( record, *args )
    options       = args.extract_options!.with_indifferent_access
    id            = idof record
    model_name    = record.class.name
    partial_name  = options[:partial] || record.class.name.underscore
    content       = javascript_object_for(render(:partial => partial_name, :object => record))
    @lines << "FT.#{model_name}.updateRow('#{id}', #{content});"
  end
  
  
  
  def refresh_records(model, *args)
    options       = args.extract_options!.with_indifferent_access
    collection    = args.first || model.all(options[:find]||{})
    model_name    = model.name
    table_name    = model_name.tableize
    partial_name  = options[:partial] || model_name.underscore
    content       = javascript_object_for(render(:partial => partial_name, :collection => collection))
    @lines << "FT.#{model_name}.updateRows(#{content});"
  end
  
  
  
  def show_error( message, *args )
    options = args.extract_options!.with_indifferent_access
    
    id = options[:error_id] || "flash_error"
    @lines << "var e = FT.$.find_by_id('#{id}');"
    @lines << "if(e) {"
    @lines <<   "FT.$.replace(e, #{message.to_json});"
    @lines <<   "FT.$.show(e);"
    @lines << "}"
  end
  
  
  
end