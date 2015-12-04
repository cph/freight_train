module FreightTrain
  module Builders
    class EditorBuilder < FormBuilder
      include ActionView::Helpers::TagHelper
      include ActionView::Helpers::FormOptionsHelper
      
      @@default_editor_builder = FreightTrain::Builders::EditorBuilder
      def self.default_editor_builder; @@default_editor_builder; end
      def self.default_editor_builder=(val); @@default_editor_builder=val; end
      
      
      # ===================================================================================================
      # ABOUT EDITOR_BUILDER
      # ===================================================================================================
      #
      # This is used to make an entire Ruby block into a single-quoted JavaScript string that,
      # when inserted into a document, creates an inline editor.
      #
      # The inline editor is created by scraping values from known places in the read-only row
      # which the user intends to edit.
      #
      # These methods are responsible for:
      #
      # (1) finding the right values in the document
      #     * These methods can rely on the JavaScript variable 'tr' which contains a
      #       Prototype-extended reference to the read-only row that user intends to edit.
      #     * Methods can concatenate the code "return null;" to prevent the editor from
      #       being shown if a critical value cannot be found.
      #
      # (2) assembling the html that describes the inline editor
      #     * The methods of this custom FormBuilder are intended to be concatenated to a
      #       single-quoted JavaScript string that returns that HTML of the inline editor.
      #     * Any method can append pure JavaScript code by concatenating "';" to close
      #       the string. Concatenate "html += '" to reopen the string.
      #     * Methods always need to leave the string open when they exit so that HTML
      #       defined in the ERB file outside of the FormBuilder will be respected. As a
      #       corollary, methods can always assume that they are concatenating to an open string.
      #
      # ===================================================================================================
      
      
      
      def initialize(object_name, object, template, options, &block)
        super
        @after_init = ""
      end
      
      delegate :capture, :to => :@template
      
      attr_reader :after_init
      
      
      
      # ===================================================================================================
      # EditorBuilder-only methods
      # ===================================================================================================
      
      def last_child_called?
        @last_child_called
      end
      
      def last_child(&block)
        if block_given?
          @last_child = @template.capture(&block)
          return ""
        else
          @last_child_called = true
          alt_content_tag(:td, (@last_child || default_last_child), :class => "last-child")
        end
      end
      
      def static_field(method, value)
        attr_name = "#{@object_name}[#{method}]".html_safe
        html_options = {
          'data-attr' => method,
          :type => "hidden",
          :value => value,
          :attr => attr_name,
          :name => attr_name
        }
        @template.tag("input", html_options)
      end
      
      def text(method, options={})
        attr_name = "#{@object_name}[#{method}]".html_safe
        concat_raw("FT.getAttrValue(tr, '#{attr_name}')")
      end
      alias :text_of :text
      alias :content_of :text
      
      def html(method, options={})
        attr_name = "#{@object_name}[#{method}]".html_safe
        concat_raw("FT.getAttrHtml(tr, '#{attr_name}')")
      end
      
      
      
      # ===================================================================================================
      # Modified FormBuilder methods
      # ===================================================================================================
      
      def check_box(method, html_options={})
        autofill!(method, html_options)
        super(method, html_options)
      end
      
      def radio_button(method, value, html_options={})
        autofill!(method, html_options)
        super(method, value, html_options)
      end
      
      def collection_select(method, collection, value_method=:id, text_method=:to_s, options={}, html_options={})
        choices = collection.collect {|i| [i.send(text_method), i.send(value_method)]}
        select(method, choices, options, html_options)
      end
      
      def grouped_collection_select(method, collection, group_method, group_label_method, option_key_method, option_value_method, options={}, html_options={})
        autofill!(method, html_options)
        options = option_groups_from_collection_for_select(collection, group_method, group_label_method, option_key_method, option_value_method)
        options.gsub!("'") { |c| "\\#{c}" } # this mess is to replace ' with \'.
        "#{tag("select", html_options, true)}#{options}</select>".html_safe
      end
      
      def hidden_field(method, html_options={})
        autofill!(method, html_options)
        super(method, html_options)
      end
      
      def select(method, choices, options={}, html_options={})
        autofill!(method, html_options)
        choices_html = choices.is_a?(String) ? choices.gsub("'") { |c| "\\#{c}" } : "'+FT.Helpers.createOptions(#{choices.to_json})+'"
        "#{tag("select", html_options, true)}#{choices_html}</select>".html_safe
      end
      
      def text_field(method, html_options={})
        autofill!(method, html_options)
        super(method, html_options)
      end
      
      def text_area(method, html_options={})
        autofill!(method, html_options)
        super(method, html_options)
      end
      
      def fields_for(method, *args, &block)
        options = args.extract_options!
        name = options[:name] || "#{@object_name}[#{method}]"
        editor = @@default_editor_builder.new(name, nil, @template, options, block)
        capture(editor, &block)
      ensure
        @after_init << editor.after_init
      end
      
      def nested_editor_for(method, options={}, &block)
        singular = method.to_s.singularize
        @after_init << "FT.Helpers.forEachRow(tr,tr_edit,'.#{singular}',function(tr,tr_edit,name){"
        super(method, options, &block)
      ensure
        @after_init << "});"
      end
      
      
      
      # ===================================================================================================
      # Deprecated methods
      # ===================================================================================================
      
      def id
        Rails.logger.info "DEPRECATED EditorBuilder#id (I don't believe this is used anywhere)"
        "'+tr.readAttribute('id').match(/\\d+/)+'"
      end
      
      def check_list_for(method, values, &block)
        Rails.logger.info "DEPRECATED EditorBuilder#check_list_for (I don't believe this is used anywhere)"
        attr_name = "#{@object_name}[#{method}]".html_safe
        @after_init << "FT.check_selected_values(tr,tr_edit,'#{attr_name}');"
        for value in values
          yield FreightTrain::Builders::CheckListBuilder.new(attr_name, [], value, @template)
        end
      end
      
      
      
    private
      
      
      
      def autofill!(method, html_options)
        attr_name = "#{@object_name}[#{method}]".html_safe
        attr_name << "[]" if html_options[:multiple]
        @after_init << "FT.copyValue(tr,tr_edit,'#{attr_name}');"
        html_options[:name] = attr_name
        html_options[:attr] = attr_name
        html_options[:id] = nil unless html_options.key?(:id)
      end
      
      
      
      def nested_editor_wrapper(method, attr_name, &block)
        singular = method.to_s.singularize
        
        # Use FT.Helpers.forEachNestedRow to create a closure where the variable 'tr'
        # refers to the nested row so that in the context of the EditorBuilder instantiated
        # by `fields_for`, 'tr' refers to the nested row rather than its parent.
        code("FT.Helpers.forEachNestedRow(tr,'.#{singular}',function(tr,i){") <<
        (fields_for(method, :name => "'+FT.$.attr(tr,'name')+'") do |f|
          nested_editor_row(f, attr_name, "'+i+'".html_safe, method, &block)
        end) <<
        code("});")
      end
      
      
      
      def default_last_child
       ('<button class="save" title="Save" name="submit" type="submit">Save</button>' <<
        '<button class="cancel" title="Cancel" onclick="window.FT.InlineEditor.close();return false;">Cancel</button>').html_safe
      end
      
      
      
      def code(string)
        ("';" << string << "html+='").html_safe
      end
      
      
      
      def concat_raw(string)
        code("html+=#{string};")
      end
      
      
      
    end
  end
end
