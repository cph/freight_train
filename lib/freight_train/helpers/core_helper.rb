module FreightTrain::Helpers::CoreHelper


  class ListBuilder

    def initialize(sym, template, options)
      @sym, @template, @options = sym, template, options
    end
    
    delegate :concat, :alt_content_tag, :fields_for, :to => :@template


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
  def list( *args, &block )
    options = args.extract_options!    
    table_name = args.last.to_s
    raise ArgumentError, "Missing table name" unless table_name.length > 0
    model_name = table_name.classify
    instance_name = table_name.singularize
    
    records = instance_variable_get "@#{table_name}"
    path = options[:path] || polymorphic_path(args)

    # put everything inside a form
    concat "<form class=\"freight_train\" model=\"#{model_name}\" action=\"#{path}\" method=\"get\">"
    concat "<input name='#{request_forgery_protection_token}' type='hidden' value='#{escape_javascript(form_authenticity_token)}'/>\n"
    concat "<input name='originating_controller' type='hidden' value='#{controller_name}'/>\n"
    
    #if( options[:partial] )

    # table
    alt_content_tag :table, :class => "list" do
      alt_content_tag :thead do
        yield ListBuilder.new(instance_name, self, options)        
      end
      alt_content_tag :tbody, :id => table_name do
        concat render(:partial => instance_name, :collection => records) unless !records or (records.length==0)
      end
    end
    concat "</form>\n"
    
    if options[:paginate]
      #concat "<tfoot>"
      concat will_paginate(records).to_s
      #concat "</tfoot>"
    end

    # generate javascript
    make_interactive path, table_name, options
  end
  alias_method :table_for, :list




  # this is a fix...
  def alt_content_tag(name, *args, &block)
    options = args.extract_options!
    name = FreightTrain::Tags[name] || name
    concat tag(name, options, true)
    if block_given?
      yield
    elsif args.first
      concat args.first
    end
    concat "</#{name}>"
  end
  
  
  def alt_tag(name, *args)
    name = FreightTrain::Tags[name] || name
    tag(name, *args)    
  end


end