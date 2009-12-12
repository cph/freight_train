module FreightTrain::Helpers::CommandHelper


  def commands_for( record, commands )
    html = ""
    if commands
      html << "<span class=\"commands\">"
      commands.each do |command|
        html << send("#{command}_command_for", record)
      end
      html << "</span>"
    end
    html
  end

  def idof( record )
    "#{record.class.name.underscore}_#{record.id}"
  end


private


  def delete_command_for( record )
    #"<a class=\"delete-command\" href=\"javascript:Generated.delete_item(#{record.id});\">delete</a>"
    # use onclick so that event stops bubbling
    #"<a class=\"delete-command\" href=\"#\" onclick=\"Generated.delete_item(#{record.id});\">delete</a>"
    "<a class=\"delete-command\" href=\"#\" onclick=\"FT.#{record.class.name}.destroy(#{record.id});\">delete</a>"
  end

end