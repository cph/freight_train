class FreightTrain::Builders::RowBuilder
  include FreightTrain::Helpers::RowHelper,
          FreightTrain::Helpers::FormattingHelper,
          ActionView::Helpers::NumberHelper,
          ERB::Util
  
  @@default_row_builder = FreightTrain::Builders::RowBuilder
  def self.default_row_builder; @@default_row_builder; end
  def self.default_row_builder=(val); @@default_row_builder=val; end

<<<<<<< HEAD:lib/freight_train/builders/row_builder.rb

=======
>>>>>>> temp2:lib/freight_train/builders/row_builder.rb
  def initialize(template, object_name, record)
    @template = template
    @object_name = object_name
    @record = record
  end

<<<<<<< HEAD:lib/freight_train/builders/row_builder.rb

  def record
    @record
  end


  # todo: move to extension of freight_train in this app?  
=======
  # todo: move to extension of freight_train in this app?
>>>>>>> temp2:lib/freight_train/builders/row_builder.rb
  def currency_of(method)
    number = @record.send method
    string = 
    if( number < 0 )
<<<<<<< HEAD:lib/freight_train/builders/row_builder.rb
      # "($<span attr=\"#{@object_name}[#{method}]\" value=\"#{number}\">#{number_to_currency -number, :unit=>""}</span>)"
      "<span class=\"negative\">($<span attr=\"#{@object_name}[#{method}]\" value=\"#{number}\">#{number_to_currency -number, :unit=>""}</span>)</span>"
=======
      "($<span attr=\"#{@object_name}[#{method}]\" value=\"#{number}\">#{number_to_currency -number, :unit=>""}</span>)"
>>>>>>> temp2:lib/freight_train/builders/row_builder.rb
    else
      "$<span attr=\"#{@object_name}[#{method}]\">#{number_to_currency number, :unit=>""}</span>"
    end
  end

  def fields_for(method, &block)
    value = @record.send method
    if value.is_a? Array
      (0...value.length).each do |i|
        #yield @@default_row_builder.new( @template, "#{@object_name}[#{method}][#{i}]", value[i] )
        yield @@default_row_builder.new( @template, "#{@object_name}[#{method}]", value[i] )
      end
    else
      yield @@default_row_builder.new( @template, "#{@object_name}[#{method}]", value )
    end
  end

<<<<<<< HEAD:lib/freight_train/builders/row_builder.rb

  #def hidden_field(*args)
  #  method = args.shift    
  #  value = args.shift || @record.send(method)
=======
>>>>>>> temp2:lib/freight_train/builders/row_builder.rb
  def hidden_field(method)
    value = @record.send method
    if value.is_a? Array
      "<span attr=\"#{@object_name}[#{method}]\" value=\"#{value.join("|")}\"></span>"
    else
      "<span attr=\"#{@object_name}[#{method}]\" value=\"#{value}\"></span>"
    end
  end

  def nested_fields_for(method, *args, &block)
    options = args.extract_options!
  
<<<<<<< HEAD:lib/freight_train/builders/row_builder.rb
    css = options[:hidden] ? "nested hidden" : "nested"
    @template.concat "<table class=\"#{css}\" attr=\"#{@object_name}[#{method}]\">"
    #html_options.each{|k,v| @template.concat " #{k}=\"#{v}\""}
    #@template.concat ">"
    
    # <<<<<<< HEAD:lib/freight_train/builders/row_builder.rb
    # i = 0
    # children = @record.send method
    # for child in children
    #   @template.concat "<tr id=\"#{method.to_s.singularize}_#{i}\">"
    # =======
    # yield NestedTableBuilder.new( @template )
=======
    @template.concat "<table class=\"nested #{options[:hidden]?"hidden":""}\" attr=\"#{@object_name}[#{method}]\""
    #html_options.each{|k,v| @template.concat " #{k}=\"#{v}\""}
    @template.concat ">"
>>>>>>> temp2:lib/freight_train/builders/row_builder.rb
    
    i = 0
    children = @record.send method
    for child in children
<<<<<<< HEAD:lib/freight_train/builders/row_builder.rb
      klass = options[:class]
      klass = klass.yield(child) if klass.is_a?(Proc)
      @template.concat "<tr id=\"#{method.to_s.singularize}_#{i}\"" << (klass ? " class=\"#{klass}\">" : ">")
    # >>>>>>> master:lib/freight_train/builders/row_builder.rb
=======
      @template.concat "<tr id=\"#{method.to_s.singularize}_#{i}\">"
>>>>>>> temp2:lib/freight_train/builders/row_builder.rb
      yield @@default_row_builder.new( @template, "#{@object_name}[#{method}]", child )
      @template.concat "</tr>"
      i += 1
    end
    @template.concat "</table>"
  end
<<<<<<< HEAD:lib/freight_train/builders/row_builder.rb


  def text_of(method)
    "<span attr=\"#{@object_name}[#{method}]\">#{h @record.send(method)}</span>"
  end


=======
  
  def text_of(method)
    "<span attr=\"#{@object_name}[#{method}]\">#{h @record.send(method)}</span>"
  end
  
>>>>>>> temp2:lib/freight_train/builders/row_builder.rb
  def toggle_of(method, *args)
    options = args.extract_options!
    value = @record.send method    
    #content = "<input type=\"checkbox\" attr=\"#{method}\" disabled=\"disabled\""
    #content << " checked=\"checked\"" if @record.send method
    #content << " />"
    content = "<div class=\"toggle #{value ? "yes" : "no"}\" attr=\"#{@object_name}[#{method}]\" value=\"#{value}\""
    content << " title=\"#{options[:title]}\"" if options[:title]
    content << "></div>"
  end
<<<<<<< HEAD:lib/freight_train/builders/row_builder.rb


=======
  
>>>>>>> temp2:lib/freight_train/builders/row_builder.rb
  def value_of(method, value_method, display_method, *args)
    options = args.extract_options!
    value = @record.send method
    value_value = value ? (value_method ? value.send(value_method) : value) : ""
    value_display = value ? (display_method ? value.send(display_method) : value) : ""
    method = options[:attr] if options[:attr]
    "<span attr=\"#{@object_name}[#{method}]\" value=\"#{value_value}\">#{value_display}</span>"    
  end
  
<<<<<<< HEAD:lib/freight_train/builders/row_builder.rb
=======

protected
>>>>>>> temp2:lib/freight_train/builders/row_builder.rb
  
end