class ActionView::Helpers::PrototypeHelper::JavaScriptGenerator

<<<<<<< HEAD:lib/freight_train/extensions/java_script_generator.rb

=======
>>>>>>> temp2:lib/freight_train/extensions/java_script_generator.rb
  def refresh( mode, record, *args )
    case mode
    when :single
      refresh_record record, *args
    else
      refresh_records record.class, *args
    end
  end
<<<<<<< HEAD:lib/freight_train/extensions/java_script_generator.rb


=======
  
>>>>>>> temp2:lib/freight_train/extensions/java_script_generator.rb
  def add_record( record, *args )
    options = args.extract_options!
    model_name = record.class.name
    partial_name = record.class.name.underscore
    insert_html  :top,
                 record.class.name.tableize,
                 :partial => (options[:partial] || ((ocn=options[:originating_controller]) ? "/#{ocn}/#{partial_name}" : partial_name)),
                 :object => record
    @lines << "FT.hookup_row('#{model_name}',$('#{idof record}'));"
    call "FT.restripe_rows"
  end

<<<<<<< HEAD:lib/freight_train/extensions/java_script_generator.rb

=======
>>>>>>> temp2:lib/freight_train/extensions/java_script_generator.rb
  def refresh_record( record, *args )
    options = args.extract_options!
    id = idof record
    model_name = record.class.name
    partial_name = record.class.name.underscore
    replace_html id,
                 :partial => (options[:partial] || ((ocn=options[:originating_controller]) ? "/#{ocn}/#{partial_name}" : partial_name)),
                 :object => record
                 #:locals => {:single => true}
    @lines << "FT.hookup_row('#{model_name}',$('#{id}'));"
  end

<<<<<<< HEAD:lib/freight_train/extensions/java_script_generator.rb

=======
>>>>>>> temp2:lib/freight_train/extensions/java_script_generator.rb
  def refresh_records( model, *args )
    options = args.extract_options!
    collection = args.first || model
    model_name = model.name
    table_name = model_name.tableize
    partial_name = model_name.underscore
    replace_html table_name,
                 :partial => (options[:partial] || ((ocn=options[:originating_controller]) ? "/#{ocn}/#{partial_name}" : partial_name)),
                 :collection => collection.find(:all, (options[:find]||{}) )
    @lines << "$('#{table_name}').select('.row').each(function(row){FT.hookup_row('#{model_name}',row);});"
  end

<<<<<<< HEAD:lib/freight_train/extensions/java_script_generator.rb

  def show_error( message, *args )
    options = args.extract_options!
    id = options[:error_id] || "flash_error"
    replace_html id, message
    show id
  end


=======
  def show_error( message )
    replace_html "flash_error", message
    show "flash_error"
  end
  
>>>>>>> temp2:lib/freight_train/extensions/java_script_generator.rb
end