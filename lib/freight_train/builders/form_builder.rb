class FreightTrain::Builders::FormBuilder < ActionView::Helpers::FormBuilder
  attr_reader :object


  def check_list_for( method, values, &block )
    #options = args.extract_options!
    array = @object.send method
    for value in values
      yield FreightTrain::Builders::CheckListBuilder.new("#{@object_name}[#{method}]", array, value, @template)
    end
  end


  # override: do arrays like attributes  
  def fields_for(method_or_object, *args, &block)
    #@template.concat "<!-- #{args.extract_options![:builder]} -->"
    if @object
      case method_or_object
      when String, Symbol
        object = @object.send method_or_object
        if object.is_a? Array
          #@template.concat "<!-- array -->"
          (0...object.length).each do |i|
            name = "#{@object_name}[#{method_or_object}_attributes][#{i}]"
            @template.fields_for(name, object[i], *args, &block)
          end
        else
          name = method_or_object
          #@template.concat "<!-- else -->"
          super(name, object, *args, &block)
        end 
        return
      end
    end
 
    super(method_or_object, *args, &block)
  end


  def hidden_field( method_or_object, *args )  
    options = args.extract_options!
 
    case method_or_object
    when String, Symbol
      method = method_or_object
      obj = @object.send method
    when Array
      obj = method_or_object
      method = ActionController::RecordIdentifier.singular_class_name(obj.first)
    else
      obj = method_or_object
      method = ActionController::RecordIdentifier.singular_class_name(obj)
    end
 
    options[:type] = "hidden"
    options[:id] = method
 
    content = ""
    content = "<!--#{@object.class}-->"
    if obj.is_a? Array
      options[:name] = "#{@object_name}[#{method}][]"
      for value in obj
      options[:value] = value
      content << @template.tag( "input", options )
      end
    else
      options[:name] = "#{@object_name}[#{method}]"
      options[:value] = obj ? "#{obj}" : ""
      content << @template.tag( "input", options )
    end
    raw content
  end


  # todo: there's a lot of duplication between this method and the one in editor_builder; is there a good way to merge them?
  def nested_editor_for( object_name, *args, &block )
    @template.instance_variable_set "@enable_nested_records", true
    i = 0
    # for some reason, things break if I make "#{@object_name}[#{object_name.to_s}_attributes]" the 'id' of the table
    @template.safe_concat "<table class=\"nested editor\" name=\"#{@object_name}[#{object_name.to_s}_attributes]\">"
    nested_fields_for object_name, *args do |f|
      @template.safe_concat "<tr id=\"#{object_name.to_s.singularize}_#{i}\" class=\"nested-row\">"
      block.call(f)

      @template.safe_concat "<td><div class=\"delete-nested\"><a class=\"delete-link\" href=\"#\" onclick=\"event.stop();FT.delete_nested_object(this);return false;\"></a></div></td>"
      @template.safe_concat "<td><div class=\"add-nested\"><a class=\"add-link\" href=\"#\" onclick=\"event.stop();FT.add_nested_object(this);return false;\"></a></div></td>"
      @template.safe_concat "</tr>"
      i += 1
    end
    @template.safe_concat "</table>"
  end

  
private


  def nested_fields_for(method_or_object, *args, &block)
    args << {:builder => FreightTrain::Builders::NestedFormBuilderWrapper}
    fields_for(method_or_object, *args, &block)    
  end


end