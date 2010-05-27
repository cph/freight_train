class FreightTrain::Builders::RowBuilder
  include FreightTrain::Helpers::RowHelper,
          FreightTrain::Helpers::FormattingHelper,
          ActionView::Helpers::NumberHelper,
          ERB::Util
  
  @@default_row_builder = FreightTrain::Builders::RowBuilder
  def self.default_row_builder; @@default_row_builder; end
  def self.default_row_builder=(val); @@default_row_builder=val; end


  def initialize(template, object_name, record)
    @template = template
    @object_name = object_name
    @record = record
  end
    
  
  delegate :concat, :raw, :alt_content_tag, :fields_for, :to => :@template


  def record
    @record
  end


  # todo: move to extension of freight_train in this app?  
  def currency_of(method)
    number = @record.send method
    string = 
    if( number < 0 )
      # "($<span attr=\"#{@object_name}[#{method}]\" value=\"#{number}\">#{number_to_currency -number, :unit=>""}</span>)"
      raw "<span class=\"negative\">($<span attr=\"#{@object_name}[#{method}]\" value=\"#{number}\">#{number_to_currency -number, :unit=>""}</span>)</span>"
    else
      raw "$<span attr=\"#{@object_name}[#{method}]\" value=\"#{number}\">#{number_to_currency number, :unit=>""}</span>"
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

  def hidden_field(method)
    value = @record.send method
    if value.is_a? Array
      raw "<span attr=\"#{@object_name}[#{method}]\" value=\"#{value.join("|")}\"></span>"
    else
      raw "<span attr=\"#{@object_name}[#{method}]\" value=\"#{value}\"></span>"
    end
  end

  def nested_fields_for(method, *args, &block)
    singular = method.to_s.singularize
    options = args.extract_options!  
    css = options[:hidden] ? "nested hidden" : "nested"
    
    alt_content_tag :table, :class => css do
      alt_content_tag :tbody, :attr => "#{@object_name}[#{method}]" do
        i = 0
        children = @record.send method
        for child in children
          klass = options[:class]
          klass = klass.call(child) if klass.is_a?(Proc)
          temp = ["nested-row", singular]
          temp << klass if klass
          klass = temp.join(" ")
          name = "#{@object_name}[#{method}_attributes][#{i}]"
          alt_content_tag :tr, :id => "#{singular}_#{i}", :class => klass, :name => name do
            f = @@default_row_builder.new(@template, name, child)
            alt_content_tag :td, :class => "hidden", :style => "display:none;" do
              concat f.hidden_field :id
            end
            yield f
          end
          i += 1
        end
      end
    end
  end


  def text_of(method)
    raw "<span attr=\"#{@object_name}[#{method}]\">#{h @record.send(method)}</span>"
  end


  def toggle_of(method, *args)
    options = args.extract_options!
    value = @record.send method    
    #content = "<input type=\"checkbox\" attr=\"#{method}\" disabled=\"disabled\""
    #content << " checked=\"checked\"" if @record.send method
    #content << " />"
    content = "<div class=\"toggle #{value ? "yes" : "no"}\" attr=\"#{@object_name}[#{method}]\" value=\"#{value}\""
    content << " title=\"#{options[:title]}\"" if options[:title]
    content << "></div>"
    raw content
  end


  def value_of(method, value_method, display_method, *args)
    options = args.extract_options!
    value = @record.send method
    value_value = value ? (value_method ? value.send(value_method) : value) : ""
    value_display = value ? (display_method ? value.send(display_method) : value) : ""
    method = options[:attr] if options[:attr]
    raw "<span attr=\"#{@object_name}[#{method}]\" value=\"#{value_value}\">#{value_display}</span>"    
  end
  

end