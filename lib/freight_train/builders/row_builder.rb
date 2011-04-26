module FreightTrain
  module Builders
    class RowBuilder
      include FreightTrain::Helpers::RowHelper,
              FreightTrain::Helpers::FormattingHelper,
              ActionView::Helpers::NumberHelper,
              ERB::Util
  
  
  
      @@default_row_builder = FreightTrain::Builders::RowBuilder
      def self.default_row_builder; @@default_row_builder; end
      def self.default_row_builder=(val); @@default_row_builder=val; end
  
  
  
      def initialize(template, object_name, record, options={})
        @template, @object_name, @record, @options = template, object_name, record, options
        @commands_called = false
      end
  
  
  
      attr_reader :object,
                  :object_name,
                  :record
      delegate    :capture,
                  :raw,
                  :raw_or_concat,
                  :alt_content_tag,
                  :fields_for,
                  :to => :@template
  
  
  
      def record
        @record
      end
  
  
  
      # todo: move to extension of freight_train in this app?  
      def currency_of(method, options={})
        number = @record.send(method) || 0
        if number < 0
          "<span attr=\"#{@object_name}[#{method}]\" value=\"#{h(number)}\" class=\"#{options[:class]} negative\">($#{h(number_to_currency -number, :unit=>"")})</span>".html_safe
        else
          "<span attr=\"#{@object_name}[#{method}]\" value=\"#{h(number)}\" class=\"#{options[:class]}\">$#{h(number_to_currency number, :unit=>"")}</span>".html_safe
        end
      end
  
  
  
      def fields_for(method, &block)
        value = @record.send method
        if value.is_a? Array
          ((0...value.length).collect {|i|
            capture(@@default_row_builder.new(@template, "#{@object_name}[#{method}]", value[i]), &block)
          }).join.html_safe
        else
          capture(@@default_row_builder.new(@template, "#{@object_name}[#{method}]", value), &block)
        end
      end
  
  
  
      def hidden_field(method, value=nil)
        value ||= @record.send(method)
        value = value.join("|") if value.is_a? Array
        "<span attr=\"#{@object_name}[#{method}]\" value=\"#{h(value)}\"></span>".html_safe
      end
  
  
  
      def nested_fields_for(method, *args, &block)
        singular = method.to_s.singularize
        options = args.extract_options!  
        css = options[:hidden] ? "nested hidden" : "nested"
        name = "#{@object_name}[#{method}_attributes]"
    
        raw_or_concat(alt_content_tag(:table, :class => css) do
          alt_content_tag(:tbody, :attr => name) do
            i = -1
            children = @record.send(method).reject {|child| child.respond_to?(:destroyed?) && child.destroyed?}
            children.collect {|child|
              i += 1
              name = "#{@object_name}[#{method}_attributes][#{i}]"
          
              klass = options[:class]
              klass = klass.call(child) if klass.is_a?(Proc)
              temp = ["nested-row", singular]
              temp << klass if klass
              klass = temp.join(" ")
          
              alt_content_tag(:tr, :id => "#{singular}_#{i}", :class => klass, :name => name) do
                f = @@default_row_builder.new(@template, name, child)
                alt_content_tag(:td, (f.hidden_field :id), :class => "hidden", :style => "display:none;") <<
                capture(f, &block)
              end
            }.join.html_safe
          end
        end)
      end
  
  
  
      def text_of(method, options={})
        "<span attr=\"#{@object_name}[#{method}]\" class=\"#{options[:class]}\">#{h(@record.send(method))}</span>".html_safe
      end
  
  
  
      def toggle_of(method, *args)
        options = args.extract_options!
        value = @record.send method
        #content = "<input type=\"checkbox\" attr=\"#{method}\" disabled=\"disabled\""
        #content << " checked=\"checked\"" if @record.send method
        #content << " />"
        content = "<div class=\"toggle #{value ? "yes" : "no"}\" attr=\"#{@object_name}[#{method}]\" value=\"#{h(value)}\""
        content << " title=\"#{options[:title]}\"" if options[:title]
        content << "></div>"
        content.html_safe
      end
      
      
      
      def value_of(method, value_method, display_method, *args)
        options = args.extract_options!
        value = @record.send method
        value_value = value ? (value_method ? value.send(value_method) : value) : ""
        value_display = value ? (display_method ? value.send(display_method) : value) : ""
        method = options[:attr] if options[:attr]
        "<span attr=\"#{@object_name}[#{method}]\" value=\"#{h(value_value)}\">#{h(value_display)}</span>".html_safe
      end
      
      
      
      def commands_called?
        @commands_called
      end
      
      
      
      def commands_for(commands)
        @commands_called = true
        html = ""
        if commands
          html << "<span class=\"commands\">"
          commands.each do |command|
            html << send("#{command}_command")
          end
          html << "</span>"
        end
        html.html_safe
      end
      
      
      
      def delete_command
        @commands_called = true
        "<a class=\"delete-command\" href=\"#\" onclick=\"Event.stop(event); FT.#{@record.class.name}.destroy(#{record.to_param.to_json});\">delete</a>".html_safe
      end
      
      
      
    end
  end
end
