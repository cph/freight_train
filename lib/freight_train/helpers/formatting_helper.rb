module FreightTrain::Helpers::FormattingHelper


  # todo: this can be deleted
  def number_to_currency(number, options={})
    if( number < 0 )
      "(#{super -number, options})"
    else
      super(number, options)
    end
  end


  # todo: this is also in lail_extensions; but FT requires it
  def format_errors( object )
    if object and object.respond_to? "errors"
      temp = "<ul>"
      object.errors.each do |k,v|
        temp << "<li>"
        temp << "<p>#{k.humanize} #{v}</p>"
        if object.respond_to? k
          value = object.send k
          temp << format_errors(value)
        end
        temp << "</li>"
      end
      temp << "</ul>"
    else
      ""
    end
  end


  def format_exception_for(record, options={})
    "<p>An error occurred while trying to #{options[:action]} #{record.class.name.titleize}:</p><ul><li>#{h $!}</li></ul>"
  end


end