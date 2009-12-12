## todo: this represents potential refactoring toward a tag-agnostic FreightTrain
## this isn't meant to be used yet

module FreightTrain::Helpers::TableHelper
  
  class TableBuilder

    def initialize(sym, template, options)
      @sym, @template, @options = sym, template, options
    end
    
    def headings(*args, &block)
      @template.concat "<tr class=\"row\">\n"
      if block_given?
        yield
      elsif args.length > 0
        args.each {|heading| @template.concat "<th>#{heading}</th>"}
      end
      @template.concat "<th class=\"last-child\"></th></tr>\n"
    end
    
    def creator(*args, &block)
      raise ArgumentError, "Missing block" unless block_given?
      new_record = args.first || @template.instance_variable_get("@#{@sym}")
      
      @template.concat "<tr id=\"add_row\" class=\"row editor new\">"
      @template.fields_for new_record, &block
      @template.concat "</tr>"
    end
    
    def editor(*args, &block)
      if block_given?
        options = args.extract_options!
        builder = FreightTrain::Builders::InlineFormBuilder.default_inline_editor_builder
 
        #@after_init_edit = "" # if !@after_init_edit
        @template.instance_variable_set("@after_init_edit", "")
        @template.instance_variable_set("@inline_editor", @template.capture do
          yield builder.new( @sym, nil, @template, options, block)
        end)
        #@template.instance_variable_set("@after_init_edit", @after_init_edit)
      else
        raise ArgumentError, "Missing block" unless block_given?      
      end
    end
    
  end

  def table_for( *args, &block )
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
    concat "<table class=\"list\">\n<thead>\n"

    if block_given?

      yield TableBuilder.new(instance_name, self, options)    

    else

    end

    # show records
    concat "</thead>\n<tbody id=\"#{table_name}\">\n"
    concat render(:partial => instance_name, :collection => records) unless !records or (records.length==0)
    concat "</tbody>\n"
    concat "</table>\n"
    concat "</form>\n"

    if options[:paginate]
      #concat "<tfoot>"
      concat will_paginate(records).to_s
      #concat "</tfoot>"
    end

    # generate javascript
    make_interactive path, table_name, options
  end


  def row_for( record, *args, &block )
    options = args.extract_options!

    unless @update_row
      css_class = "row"
      if options[:disabled]
        css_class << " disabled"
      else
        css_class << " interactive editable"
      end

      # this makes striping work on IE7 and Firefox 3
      alt = !@template.instance_variable_get("@alt")
      @template.instance_variable_set("@alt", alt)
      css_class << " alt" if !alt

      concat "<tr class=\"#{css_class}\" id=\"#{idof record}\">"
    end

    name = ActionController::RecordIdentifier.singular_class_name(record)
    yield FreightTrain::Builders::RowBuilder.default_row_builder.new(self, name, record)

    # IE7 doesn't support the CSS selector :last-child, therefore, we do this explicitly
    #concat "<td>#{commands_for(record, options[:commands])}</td>"
    concat "  <td class=\"last-child\">#{commands_for(record, options[:commands])}</td>\n"

    concat "</tr>\n" unless @update_row
  end

  def idof( record )
    "#{record.class.name.underscore}_#{record.id}"
  end


private


end