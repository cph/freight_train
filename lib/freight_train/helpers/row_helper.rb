module FreightTrain::Helpers::RowHelper
    
  
  # delegate :concat, :alt_content_tag, :fields_for, :to => :@template

  attr_reader :model_name # !HACK!
  
  def row_for(record, *args, &block)
    options = args.extract_options!
    singular = record.class.name.tableize.singularize
#    model_name = instance_variable_get("@model_name") # !HACK!
    
    if @update_row
      row_guts_for(record, options, &block)
    else
      css = ["row", singular]
      css.concat options[:disabled] ? ["disabled"] : ["interactive", "editable"]
 
      # this makes striping work on IE7 and Firefox 3
      alt = !@template.instance_variable_get("@alt")
      @template.instance_variable_set("@alt", alt)
      css << "alt" if !alt
      css << options[:class] if options[:class]
 
      alt_content_tag :tr, :class => css.join(" "), :id => idof(record) do
        row_guts_for(record, options, &block)
      end
    end
  end


  def commands_for( record, commands )
    html = ""
    if commands
      html << "<span class=\"commands\">"
      commands.each do |command|
        html << send("#{command}_command_for", record)
      end
      html << "</span>"
    end
    raw (html)
  end


  def idof( record )
    "#{record.class.name.underscore}_#{record.id}"
  end


private


  def row_guts_for(record, options, &block)
    name = ActionController::RecordIdentifier.singular_class_name(record)
    yield FreightTrain::Builders::RowBuilder.default_row_builder.new(self, name, record)

    # IE7 doesn't support the CSS selector :last-child, therefore, we do this explicitly
    #concat "<td>#{commands_for(record, options[:commands])}</td>"
    #concat "  <td class=\"last-child\">#{commands_for(record, options[:commands])}</td>\n"
    alt_content_tag :td, :class => "last-child" do
      concat commands_for(record, options[:commands])
    end
  end


  def delete_command_for( record )
    #"<a class=\"delete-command\" href=\"javascript:Generated.delete_item(#{record.id});\">delete</a>"
    # use onclick so that event stops bubbling
    #"<a class=\"delete-command\" href=\"#\" onclick=\"Generated.delete_item(#{record.id});\">delete</a>"
    "<a class=\"delete-command\" href=\"#\" onclick=\"Event.stop(event); FT.#{model_name}.destroy(#{record.id});\">delete</a>"
  end


end