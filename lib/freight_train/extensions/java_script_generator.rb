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
    @lines << "FT.adapter().fire(FT.adapter().find_by_id('#{id}'), 'ft:#{event}');"
  end
  
  
  
  def safe_hide(*ids)
    ids.each do |id|
      @lines << "FT.adapter().hide(FT.adapter().find_by_id('#{id}'));"
    end
  end
  
  
  
  def add_record(record, *args)
    options = args.extract_options!.with_indifferent_access
    
    model_name = record.class.name
    partial_name = options[:partial] || record.class.name.underscore
    insert_html  :top,
                 record.class.name.tableize,
                 :partial => partial_name,
                 :object => record
    @lines << "FT.#{model_name}.hookupRow(FT.adapter().find_by_id('#{idof record}'));"
    call "FT.Helpers.restripeRows"
  end
  
  
  
  def refresh_record( record, *args )
    options = args.extract_options!.with_indifferent_access
    
    id = idof record
    model_name = record.class.name
    partial_name = options[:partial] || record.class.name.underscore
    replace_html id,
                 :partial => partial_name,
                 :object => record
    @lines << "FT.#{model_name}.hookupRow(FT.adapter().find_by_id('#{id}'));"
  end
  
  
  
  def refresh_records(model, *args)
    options = args.extract_options!.with_indifferent_access
    
    collection = args.first || model.all(options[:find]||{})
    model_name = model.name
    table_name = model_name.tableize
    partial_name = options[:partial] || model_name.underscore
    replace_html(table_name, :partial => partial_name, :collection => collection)
    call "FT.#{model_name}.hookupRows"
  end
  
  
  
  def show_error( message, *args )
    options = args.extract_options!.with_indifferent_access
    
    id = options[:error_id] || "flash_error"
    replace_html id, message
    show id
  end
  
  
  
end