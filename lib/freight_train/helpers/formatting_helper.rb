module FreightTrain
  module Helpers
    module FormattingHelper


      # !todo: this is simply copied for lail_extensions' FormattingHelper!
      def format_errors( object )
        if object and object.respond_to?("errors") and !(messages = object.errors.all_messages).empty?
          ("<ul>" + messages.collect{|msg| "<li>#{msg}</li>"}.join + "</ul>").html_safe
        else
          ""
        end    
=begin
    if object and object.respond_to? "errors"
      temp = "<ul>"
      object.errors.each do |k,v|
        temp << "<li>"
        temp << "<p>#{k.to_s.humanize} #{v}</p>"
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
=end    
      end


      def format_exception_for(record, options={})
        "<p>An error occurred while trying to #{options[:action] || "access"} #{record.class.name.titleize}:</p><ul><li>#{h $!}</li></ul>".html_safe
      end
      
    end
  end
end