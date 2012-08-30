module FreightTrain
  module Builders
    class FormBuilder < ActionView::Helpers::FormBuilder
      
      attr_reader :object
      
      delegate :capture, :raw, :raw_or_concat, :alt_content_tag, :alt_tag, :to => :@template
      
      
      
      def check_list_for( method, values, &block )
        #options = args.extract_options!
        array = @object.send method
        for value in values
          yield FreightTrain::Builders::CheckListBuilder.new("#{@object_name}[#{method}]", array, value, @template)
        end
      end
      
      
      
      # override: do arrays like attributes  
      def fields_for(method_or_object, *args, &block)
        options = args.extract_options!
        if @object
          case method_or_object
          when String, Symbol
            object = @object.send method_or_object
            if object.is_a? Array
              name = options[:name] || "#{@object_name}[#{method_or_object}_attributes]"
              return ((0...object.length).collect do |i|
                @template.fields_for("#{name}[#{i}]", object[i], *args, &block)
              end).join.html_safe
            else
              name = options[:name] || method_or_object
              #@template.concat "<!-- else -->"
              return super(name, object, *args, &block)
            end
          end
        end
        
        super(method_or_object, *args, &block)
      end
      
      
      
      def hidden_field(method_or_object, *args)
        method = case method_or_object
        when String, Symbol; method_or_object
        when Array; obj.first.class.name.tableize.singularize
        else; obj.class.name.tableize.singularize
        end
        
        html_options = args.extract_options!
        html_options[:id] = html_options[:name].parameterize.underscore if html_options[:name] && !html_options.key?(:id)
        html_options["data-attr"] = method
        
        super(method_or_object, html_options)
      end
      
      # def hidden_field(method_or_object, *args)
      #   options = args.extract_options!
      #   
      #   case method_or_object
      #   when String, Symbol
      #     method = method_or_object
      #     obj = @object ? @object.send(method) : nil
      #   when Array
      #     obj = method_or_object
      #     method = obj.first.class.name.tableize.singularize
      #   else
      #     obj = method_or_object
      #     method = obj.class.name.tableize.singularize
      #   end
      #   
      #   options[:type] = "hidden"
      #   options["data-attr"] = method
      #   options[:name] = "#{@object_name}[#{method}]".html_safe # !hack: figure out how to implement the commented-out method above
      #   options[:id] = options[:name].parameterize.underscore
      #   
      #   content = ""
      #   content = "<!--#{@object.class}-->"
      #   if obj.is_a? Array
      #     options[:name] = "#{options[:name]}[]".html_safe # !hack: figure out how to implement the commented-out method above
      #     for value in obj
      #       value.nil? ? options.delete(:value) : (options[:value] = value)
      #       content << @template.tag( "input", options )
      #     end
      #   else
      #     obj = obj.to_s
      #     obj.blank? ? options.delete(:value) : (options[:value] = obj)
      #     content << @template.tag( "input", options )
      #   end
      #   content.html_safe
      # end
      
      
      
      def static_field(method, value)
        attr_name = "#{@object_name}[#{method}]"
        html_options = {
          'data-attr' => method,
          :type => "hidden",
          :value => value,
          :attr => attr_name,
          :name => attr_name
        }
        @template.tag("input", html_options)
      end
      
      
      
      def nested_editor_for(method, *args, &block)
        raise ArgumentError, "Missing block" unless block_given?
        
        @template.instance_variable_set "@enable_nested_records", true
        
        attr_name = "#{@object_name}[#{method}_attributes]"
        
        # for some reason, things break if I make "#{@object_name}[#{object_name.to_s}_attributes]" the 'id' of the table
        alt_content_tag(:table, :class => "nested editor") do
          alt_content_tag(:tbody, :attr => attr_name) do
            nested_editor_wrapper(method, attr_name, &block)
          end
        end
      end
      
      
      
    protected
      
      
      
      def nested_editor_wrapper(method, attr_name, &block)
        i = -1
        fields_for(method, :name => attr_name) do |f|
          i += 1
          nested_editor_row(f, attr_name, i, method, &block)
        end
      end
      
      def nested_editor_row(f, attr_name, i, method, &block)
        singular = method.to_s.singularize
        attr_name = "#{attr_name}[#{i}]".html_safe # for sake of EditorBuilder which wants to pass "'+i+'"
        html_options = {
          :class => "nested-row #{singular}",
          :id => "#{singular}_#{i}".html_safe, # for sake of EditorBuilder which wants to pass "'+i+'"
          :name => attr_name,
          :attr => attr_name
        }
        alt_content_tag(:tr, html_options) do
          nested_row_hidden_properties(f) <<
          capture(f, &block) <<
          delete_nested_command <<
          add_nested_command
        end
      end
      
      def nested_row_hidden_properties(f)
        alt_content_tag(:td, :class => "hidden") do
          (f.hidden_field :id) <<
          (f.static_field :_destroy, (f.object.respond_to?(:_destroy) && f.object._destroy) ? 1 : 0)
        end
      end
      
      def delete_nested_command
        alt_content_tag(:td, :class => "delete-nested") do
          "<a class=\"delete-link delete-nested-link\" href=\"#\" title=\"Delete\">Delete</a>".html_safe
        end
      end
      
      def add_nested_command
        alt_content_tag(:td, :class => "add-nested") do
          "<a class=\"add-link add-nested-link\" href=\"#\" title=\"Add\">Add</a>".html_safe
        end
      end
      
      
      
    end
  end
end