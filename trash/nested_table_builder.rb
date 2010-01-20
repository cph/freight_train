# Is this used?


class FreightTrain::Builders::NestedTableBuilder
    
  
  # delegate :concat, :alt_content_tag, :fields_for, :to => :@template


  def initialize(template)
    @template = template
    @i = 0
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

      #concat "<tr class=\"#{css_class}\" id=\"#{idof record}\">"
      concat alt_tag(:tr, :class => css_class, :id => idof(record))
    end

    name = ActionController::RecordIdentifier.singular_class_name(record)
    yield FreightTrain::Builders::RowBuilder.default_row_builder.new(self, name, record)

    # IE7 doesn't support the CSS selector :last-child, therefore, we do this explicitly
    #concat "<td>#{commands_for(record, options[:commands])}</td>"
    # concat "  <td class=\"last-child\">#{commands_for(record, options[:commands])}</td>\n"
    alt_content_tag :td, :class => "last-child" do
      commands_for(record, options[:commands])
    end

    #concat "</tr>\n" unless @update_row
    concat "</#{FreightTrain::Tags[:tr] || :tr}>" unless @update_row
  end
  
  
end