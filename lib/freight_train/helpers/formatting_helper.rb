module FreightTrain::Helpers::FormattingHelper


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