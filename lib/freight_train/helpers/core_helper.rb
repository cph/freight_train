module FreightTrain::Helpers::CoreHelper


  class ListBuilder

    def initialize(sym, template, options)
      @sym, @template, @options = sym, template, options
      @html = ""
    end
    
    delegate :capture, :raw, :alt_content_tag, :fields_for, :to => :@template


    def headings(*args, &block)
      headings = block_given? ? capture(&block) : args.collect{|heading| alt_content_tag(:th, heading)}.join
      headings << alt_content_tag(:th)
      alt_content_tag(:tr, headings, :class => "row heading")      
    end
    
    
    def creator(*args, &block)
      raise ArgumentError, "Missing block" unless block_given?
      new_record = args.first || @template.instance_variable_get("@#{@sym}")
      
      alt_content_tag(:tr, :id => "add_row", :class => "row editor new") do
        fields_for new_record, &block
      end
    end
    
    
    def editor(*args, &block)
      raise ArgumentError, "Missing block" unless block_given?
      options = args.extract_options!
      builder = FreightTrain::Builders::EditorBuilder.default_editor_builder
      editor_builder = builder.new(@sym, nil, @template, options, block)
 
      #@after_init_edit = "" # if !@after_init_edit
      @template.instance_variable_set("@after_init_edit", "")
      @template.instance_variable_set("@inline_editor", capture(editor_builder, &block) + editor_builder.last_child)
      #@template.instance_variable_set("@after_init_edit", @after_init_edit)
      "" # @inline_editor is saved for later; don't print it out here
    end
    
    
    def to_s
    end
    
    
  end


  # todo: write usage here
  #
  #  :paginate => [true, false]     -
  #  :path =>                       -
  def list(*args, &block)
    tags = {
      :table => :div,
      :tbody => :ol,
      :thead => :ol,
      :tr => :li,
      :th => :div,
      :td => :div
    }
    ft_generate_html tags, *args, &block
  end

  # todo: write usage here
  #
  #  :paginate => [true, false]     -
  #  :partial =>                    -
  #  :path =>                       -
  def table_for(*args, &block)
    tags = {
      :table => :table,
      :thead => :thead,
      :tbody => :tbody,
      :tr => :tr,
      :th => :th,
      :td => :td
    }
    ft_generate_html tags, *args, &block
  end




  # this is a fix...
  #                 ...for what?
  def alt_content_tag(name, *args, &block)
    options = args.extract_options!
    name = FreightTrain.tag(name)
    content = block_given? ? capture(&block) : args.first
    content_tag(name, content, options)
    #content_tag(name, *args, &block)
  end
  
  
  def alt_tag(name, *args)
    name = FreightTrain.tag(name)
    tag(name, *args)    
  end
  
  
private


  def ft_generate_html(tags, *args, &block)
    # todo: pass these tags as a parameter; don't rely on ugly globals
    FreightTrain.tags = tags
    
    options = args.extract_options!    
    table_name = args.last.to_s
    raise ArgumentError, "Missing table name" if table_name.blank?
    model_name = table_name.classify
    instance_name = table_name.singularize
    partial = options[:partial] || instance_name
    
    records = instance_variable_get("@#{table_name}")
    path = options[:path] || polymorphic_path(args)

    # put everything inside a form
    raw(
      "<form class=\"freight_train\" data-model=\"#{model_name}\" action=\"#{path}\" method=\"get\">" <<
      "<input name=\"#{request_forgery_protection_token}\" type=\"hidden\" value=\"#{escape_javascript(form_authenticity_token)}\"/>\n" <<
      "<input name=\"ft[partial]\" type=\"hidden\" value=\"#{partial}\"/>\n" <<
    
    #if( options[:partial] )

      # table
      alt_content_tag(:table, :class => "list") {
        alt_content_tag(:thead) {
          capture(ListBuilder.new(instance_name, self, options), &block) if block_given?
        } <<
        alt_content_tag(:tbody, :id => table_name) {
          render(:partial => partial, :collection => records) unless !records or (records.length==0)
        }
      } <<
      "</form>\n" <<
    
      "#{will_paginate(records) if options[:paginate]}" <<

      # generate javascript
      make_interactive(path, table_name, options)
    )
  end


end