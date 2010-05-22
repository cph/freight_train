class FreightTrain::Builders::EditorBuilder < FreightTrain::Builders::FormBuilder
  include ActionView::Helpers::TagHelper

  @@default_editor_builder = FreightTrain::Builders::EditorBuilder
  def self.default_editor_builder; @@default_editor_builder; end
  def self.default_editor_builder=(val); @@default_editor_builder=val; end
  
  
  # TODO: Push this into a JavaScript library
  #   1. allow base class to generate controls
  #      a. use @after_init_edit method to assign values to controls
  #      b. ** come up with mechanism to set field and id for nested values (or use another method to identify them) **
  #   2. refactor to put @after_init_edit method into before- or after- filter
  #      a. abstract value assignment for (e.g.) INPUT[TYPE="TEXT"] and SELECT and INPUT[TYPE="CHECKBOX"]
  #      b. call generic value assignment in before/after filters and push logic to core.js
  
  
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
    

  def initialize(object_name, object, template, options, proc)
    super
    @after_init_edit = @template.instance_variable_get("@after_init_edit")
  end
  
  
  # delegate :concat, :raw, :safe_concat, :alt_content_tag, :alt_tag, :to => :@template
  delegate :capture, :to => :@template


  def check_box(method, options={})
    attr_name = "#{@object_name}[#{method}]"
    raw code(
      "e = tr.down('*[attr=\"#{attr_name}\"]');if(!e){alert('#{attr_name} not found');return null;}" <<
      "var checked = (e.readAttribute('value')=='true');"
    ) <<
      "<input name=\"#{attr_name}\" type=\"hidden\" value=\"0\"/>" <<
      "<input name=\"#{attr_name}\" type=\"checkbox\"'+(checked ? 'checked=\"checked\"' : '')+' value=\"1\" />"
  end


  def check_list_for(method, values, &block)
    attr_name = "#{@object_name}[#{method}]"
    @after_init_edit << "FT.check_selected_values(tr,tr_edit,'#{attr_name}');"
    for value in values
      yield FreightTrain::Builders::CheckListBuilder.new(attr_name, [], value, @template)
    end
  end


  def collection_select(method, collection, value_method, text_method, options = {}, html_options = {})
    attr_name = "#{@object_name}[#{method}]"
    @after_init_edit << "FT.copy_selected_value(tr,tr_edit,'#{attr_name}','#{method}');"

    html_options[:id] = method unless html_options[:id]
    html_options[:name] = attr_name
    
    o = "["
    collection.each do |i|
      o << "," if (o.length > 1)
      # prevent options that contain apostrophes from screwing things up
      o << "['#{i.send(value_method).to_s.gsub( Regexp.new("'"), "\\\\'")}','#{i.send(text_method).to_s.gsub( Regexp.new("'"), "\\\\'")}']"
    end
    o << "]"
    
    raw "#{tag("select", html_options, true)}'+FT.create_options(#{o})+'</select>"
  end


  def fields_for(method, *args, &block)
    options = args.extract_options!
    yield @@default_editor_builder.new( "#{@object_name}[#{method}]", nil, @template, options, block )
    #capture(@@default_editor_builder.new( "#{@object_name}[#{method}]", nil, @template, options, block ), &block)
  end


  def id
    "'+tr.readAttribute('id').match(/\\d+/)+'"
  end


  def static_field( method, value )
    @template.tag( "input", {
      :id => method,
      :class => "field",
      :type=>"hidden",
      :value=>value,
      :name=>"#{@object_name}[#{method}]"} )
  end  


  def hidden_field( method )
    options = { :type => "hidden" }
        
    raw code(
      "e=tr.select('*[attr=\"#{@object_name}[#{method}]\"]');" <<
      "if(e.length==1){"
    ) <<
      
      @template.tag( "input", {
        :type=>"hidden",
        :class => "field",
        :id => method,
        :value=>"'+e[0].readAttribute('value')+'",
        :name=>"#{@object_name}[#{method}]"} ) <<
      
    code(
      "}else{" <<
        "for(var i=0; i<e.length; i++){"
    ) <<
    
      @template.tag( "input", {
        :type=>"hidden",        
        :class => "field",
        :id => method,
        :value=>"'+e[i].readAttribute('value')+'",
        :name=>"#{@object_name}[#{method}][]"} ) <<
    
    code(
        "}" <<
      "}"
    )
  end


  def nested_editor_for( method, *args, &block )
    raise ArgumentError, "Missing block" unless block_given?
    options = args.extract_options!
    
    attr_name = "#{@object_name}[#{method}]"
    name = "#{@object_name}[#{method}_attributes]"
    singular = method.to_s.singularize
    @template.instance_variable_set "@enable_nested_records", true

    # for some reason, things break if I make "#{@object_name}[#{object_name.to_s}_attributes]" the 'id' of the table
    alt_content_tag :tbody, :class => "nested editor", :name => name do
      #alt_content_tag :tbody do
      
        old_after_init_edit = @after_init_edit
        @after_init_edit = ""
  
        # This FormBuilder expects 'tr' to refer to a TR that represents and object and contains
        # TDs representing the object's attributes. For nested objects, the TR is a child of the
        # root TR. Create a closure in which the variable 'tr' refers to the nested object while
        # preserving the reference to the root TR.
        html = code(
          "(function(root_tr){" <<
          "var nested_rows=root_tr.select('*[attr=\"#{attr_name}\"] .#{singular}');" <<
          #"alert('#{attr_name}: '+nested_rows.length);" <<
          "for(var i=0; i<nested_rows.length; i++){" << 
            "var tr=nested_rows[i];"
        ) <<
        (fields_for method, nil, *args do |f|
          alt_content_tag :tr, :class => "nested-row", :id => "#{method.to_s.singularize}_'+i+'" do
            (alt_content_tag :td, :class => "hidden" do
              (f.hidden_field :id) <<
              #safe_concat "<input type=\"hidden\" name=\"#{@object_name}[#{method}][_delete]\" value=\"false\" />"
              (f.static_field :_destroy, 0)
            end) <<
            #(yield f) <<  # why is this a yield and not a capture?
            capture(f, &block) <<
            (alt_content_tag :td, :class => "delete-nested" do
              "<a class=\"delete-link\" href=\"#\" onclick=\"event.stop();FT.delete_nested_object(this);return false;\"></a>"
            end) <<
            (alt_content_tag :td, :class => "add-nested" do
              "<a class=\"add-link\" href=\"#\" onclick=\"event.stop();FT.add_nested_object(this);return false;\"></a>"
            end)
          end
        end) <<
        code( "}})(tr);" )
        
        if @after_init_edit.empty?
          @after_init_edit = old_after_init_edit
        else
          @after_init_edit = old_after_init_edit + "FT.for_each_row(tr,tr_edit,'*[attr=\"#{attr_name}\"] .row','*[name=\"#{name}\"] .row',function(tr,tr_edit){#{@after_init_edit}});"
        end
        
        html
        
      #end
    end
  end



  def select(method, choices, options = {}, html_options = {})
    attr_name = "#{@object_name}[#{method}]"
    @after_init_edit <<
      "var e = tr.down('*[attr=\"#{attr_name}\"]');" <<
      "var sel = tr_edit.down('select[name=\"#{attr_name}\"]');" <<
      "if(sel && e) FT.select_value(sel,e.readAttribute('value'));" <<
      "else{if(!e) alert('#{attr_name} not found');if(!sel) alert('#{method} not found');}"
    super
  end


  def text(method, options={})
    attr_name = "#{@object_name}[#{method}]"
    raw code(
      "e=tr.down('*[attr=\"#{attr_name}\"]');" <<
      "if(!e){alert('#{attr_name} not found'); return null;}" <<
    # "alert(e.innerHTML);" <<
      "html += e.innerHTML;"
    )
  end


  # assign value after creation of control

  def text_field(method, options={})
    attr_name = "#{@object_name}[#{method}]"
    options[:id] = method unless options[:id]
    raw code(
      "e=tr.down('*[attr=\"#{attr_name}\"]');" <<
      "if(!e){alert('#{attr_name} not found'); return null;}" <<
    # "alert(e.innerHTML);" <<
      "var #{method}=e.readAttribute('value')||e.innerHTML;"
    ) << 
    @template.tag( "input", options.merge(
      :type => "text",
      :name => "#{attr_name}",
      :value => "'+#{method}.toString()+'"))
  end

=begin
  def text_field(method, options={})
    attr_name = "#{@object_name}[#{method}]"
    @after_init_edit <<
      "var e = tr.down('*[attr=\"#{attr_name}\"]');" <<
      "var i = tr_edit.down('input[name=\"#{attr_name}\"]');" <<
      "if(i && e) { i.value = e.readAttribute('value')||e.innerHTML; }" <<
      "else{if(!e) alert('#{attr_name} not found');if(!i) alert('#{method} not found');}"
    super method, options
  end
=end
  
  
  def last_child(&block)
    if block_given?
      @last_child = @template.capture(&block)
      return ""
    else
      alt_content_tag(:td, (@last_child || default_last_child), :class => "last-child")
    end
=begin
    name = FreightTrain.tag(:td)
    html = tag(name, {:class => "last-child"}, true)
    html << (@last_child || default_last_child )
    html << raw("</#{name}>")
    raw html
=end
  end

  
private


  def default_last_child
    '<button id="tag_submit" name="commit" type="submit">Save</button>' +
    '<button onclick="InlineEditor.close();return false;">Cancel</button>'    
  end


  #def concat(x)
  #  @template.concat(x)
  #end


  def code(string)
    "';" << string << "html+='"
  end


end