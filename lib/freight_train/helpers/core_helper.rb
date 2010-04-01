module FreightTrain::Helpers::CoreHelper


  class ListBuilder

    def initialize(sym, template, options)
      @sym, @template, @options = sym, template, options
    end
    
    delegate :concat, :safe_concat, :raw, :alt_content_tag, :fields_for, :to => :@template


    def headings(*args, &block)
      alt_content_tag :tr, :class => "row heading" do
        if block_given?
          yield
        elsif args.length > 0
          args.each {|heading| alt_content_tag(:th, heading)}
        end
        alt_content_tag :th
      end
      #@template.concat "<th></th></tr>\n"
    end
    
    
    def creator(*args, &block)
      raise ArgumentError, "Missing block" unless block_given?
      new_record = args.first || @template.instance_variable_get("@#{@sym}")
      
      alt_content_tag :tr, :id => "add_row", :class => "row editor new" do
        fields_for new_record, &block
      end
      #@template.concat "<tr id=\"add_row\" class=\"row editor new\">"
      #@template.fields_for new_record, &block
      #@template.concat "</tr>"
    end
    
    
    def editor(*args, &block)
      raise ArgumentError, "Missing block" unless block_given?
      options = args.extract_options!
      builder = FreightTrain::Builders::EditorBuilder.default_editor_builder
 
      #@after_init_edit = "" # if !@after_init_edit
      @template.instance_variable_set("@after_init_edit", "")
      @template.instance_variable_set("@inline_editor", @template.capture do
        yield (editor_builder = builder.new( @sym, nil, @template, options, block))
        concat editor_builder.last_child
      end)
      #@template.instance_variable_set("@after_init_edit", @after_init_edit)
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
    safe_concat tag(name, options, true)
    if block_given?
      yield
    elsif args.first
      safe_concat args.first
    end
    safe_concat "</#{name}>"
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
    
    records = instance_variable_get "@#{table_name}"
    path = options[:path] || polymorphic_path(args)

    # put everything inside a form
    # todo: (re: model) supposed to start user-defined attributes with data-
    safe_concat "<form class=\"freight_train\" model=\"#{model_name}\" action=\"#{path}\" method=\"get\">"
    safe_concat "<input name=\"#{request_forgery_protection_token}\" type=\"hidden\" value=\"#{escape_javascript(form_authenticity_token)}\"/>\n"
    safe_concat "<input name=\"ft[partial]\" type=\"hidden\" value=\"#{partial}\"/>\n"
    # safe_concat "<input name=\"originating_controller\" type=\"hidden\" value=\"#{controller_name}\"/>\n"
    
    #if( options[:partial] )

    # table
    alt_content_tag :table, :class => "list" do
      alt_content_tag :thead do
        yield ListBuilder.new(instance_name, self, options) if block_given?
      end
      alt_content_tag :tbody, :id => table_name do
        safe_concat render(:partial => partial, :collection => records) unless !records or (records.length==0)
      end
    end
    safe_concat "</form>\n"
    
    if options[:paginate]
      #concat "<tfoot>"
      concat will_paginate(records).to_s
      #concat "</tfoot>"
    end

    # generate javascript
    make_interactive path, table_name, options 
  end


end