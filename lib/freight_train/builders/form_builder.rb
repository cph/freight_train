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
        #@template.concat "<!-- #{args.extract_options![:builder]} -->"
        if @object
          case method_or_object
          when String, Symbol
            object = @object.send method_or_object
            if object.is_a? Array
              #@template.concat "<!-- array -->"
              return ((0...object.length).collect do |i|
                name = options[:name] || "#{@object_name}[#{method_or_object}_attributes][#{i}]"
                @template.fields_for(name, object[i], *args, &block)
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
        options = args.extract_options!
    
        case method_or_object
        when String, Symbol
          method = method_or_object
          obj = @object ? @object.send(method) : nil
        when Array
          obj = method_or_object
          # method = ActionController::RecordIdentifier.singular_class_name(obj.first)
          method = obj.first.class.name.tableize.singularize
        else
          obj = method_or_object
          # method = ActionController::RecordIdentifier.singular_class_name(obj)
          method = obj.class.name.tableize.singularize
        end
    
        options[:type] = "hidden"
    
        content = ""
        content = "<!--#{@object.class}-->"
        if obj.is_a? Array
          options[:name] = "#{@object_name}[#{method}][]"
          options["data-attr"] = method
          options[:id] = options[:name].parameterize.underscore
          for value in obj
            value.nil? ? options.delete(:value) : (options[:value] = value)
            content << @template.tag( "input", options )
          end
        else
          options[:name] = "#{@object_name}[#{method}]"
          options["data-attr"] = method
          options[:id] = options[:name].parameterize.underscore
          obj = obj.to_s
          obj.blank? ? options.delete(:value) : (options[:value] = obj)
          # options[:value] = obj ? "#{obj}" : ""
          content << @template.tag( "input", options )
        end
        content.html_safe
      end
  
  
  
      def static_field(method_or_object, *args)
        hidden_field(method_or_object, *args)
      end
  
  
  
      # !todo: there's _a lot_ of duplication between this method and the one in editor_builder; is there a good way to merge them?
      def nested_editor_for(method, *args, &block)
        attr_name = "#{@object_name}[#{method}]"
        name = "#{@object_name}[#{method}_attributes]"
        singular = method.to_s.singularize
        @template.instance_variable_set "@enable_nested_records", true
    
        i = 0
        # for some reason, things break if I make "#{@object_name}[#{object_name.to_s}_attributes]" the 'id' of the table
        raw_or_concat(alt_content_tag(:table, :class => "nested editor") {
          alt_content_tag(:tbody, :attr => name) do
            name = "#{@object_name}[#{method}_attributes][#{i}]"
    #       nested_fields_for(method, *args) do |f|
            fields_for method, :name => name do |f|
              name = "#{@object_name}[#{method}_attributes][#{i}]"
              html = alt_content_tag(:tr, :class => "nested-row #{singular}", :id => "#{method.to_s.singularize}_#{i}", :name => name) {
                (alt_content_tag(:td, :class => "hidden") {
                  f.hidden_field(:id) <<
                  #safe_concat "<input type=\"hidden\" name=\"#{@object_name}[#{method}][_delete]\" value=\"false\" />"
                  f.static_field(:_destroy, 0)
                }) <<
                capture(f, &block) <<
                (alt_content_tag(:td, :class => "delete-nested") {
                  "<a class=\"delete-link\" href=\"#\" title=\"Delete\" onclick=\"Event.stop(event);FT.delete_nested_object(this);return false;\">Delete</a>".html_safe
                }) << 
                (alt_content_tag(:td, :class => "add-nested") {
                  "<a class=\"add-link\" href=\"#\" title=\"Add\" onclick=\"Event.stop(event);FT.add_nested_object(this);return false;\">Add</a>".html_safe
                })
              }
              i += 1
              html
            end
          end
        })
=begin
    @template.safe_concat "<table class=\"nested editor\" name=\"#{@object_name}[#{object_name.to_s}_attributes]\">"
    nested_fields_for object_name, *args do |f|
      @template.safe_concat "<tr id=\"#{object_name.to_s.singularize}_#{i}\" class=\"nested-row\">"
      block.call(f)

      "<td><div class=\"delete-nested\"><a class=\"delete-link\" href=\"#\" onclick=\"Event.stop(event);FT.delete_nested_object(this);return false;\"></a></div></td>" <<
      "<td><div class=\"add-nested\"><a class=\"add-link\" href=\"#\" onclick=\"Event.stop(event);FT.add_nested_object(this);return false;\"></a></div></td>" <<
      "</tr>" <<
      i += 1
    end
    @template.safe_concat "</table>"
=end
      end
  
  
    protected


# !todo: almost -- this one just has the '+i+' in nested-row
=begin
  def fields_for_nested_editor(method_or_object, *args, &block)
    fields_for(method, *args) do |f|
      alt_content_tag :tr, :class => "nested-row", :id => "#{method.to_s.singularize}_'+i+'" do
        alt_content_tag :td, :class => "hidden" do
          safe_concat f.hidden_field :id
          #safe_concat "<input type=\"hidden\" name=\"#{@object_name}[#{method}][_delete]\" value=\"false\" />"
          safe_concat f.static_field :_destroy, 0
        end
        yield f
        alt_content_tag :td, :class => "delete-nested" do
          safe_concat "<a class=\"delete-link\" href=\"#\" onclick=\"Event.stop(event);FT.delete_nested_object(this);return false;\"></a>"
        end
        alt_content_tag :td, :class => "add-nested" do
          safe_concat "<a class=\"add-link\" href=\"#\" onclick=\"Event.stop(event);FT.add_nested_object(this);return false;\"></a>"
        end
      end
    end
  end
=end

  
    private

=begin
  def nested_fields_for(method_or_object, *args, &block)
    args << {:builder => FreightTrain::Builders::NestedFormBuilderWrapper}
    fields_for(method_or_object, *args, &block)    
  end
=end


    end
  end
end