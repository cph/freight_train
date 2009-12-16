require 'rails3_backport/mime'


class ActionController::Request


  def format(view_path = [])
    formats.first
  end


  def formats
    accept = @env['HTTP_ACCEPT']

    @env["action_dispatch.request.formats"] ||=
      if parameters[:format]
        Array.wrap(Mime[parameters[:format]])
      elsif xhr? || (accept && !accept.include?(?,))
        accepts
      else
        [Mime::HTML]
      end
  end


  def format=(extension)
    parameters[:format] = extension.to_s
    @env["action_dispatch.request.formats"] = [Mime::Type.lookup_by_extension(parameters[:format])]
  end


  # Receives an array of mimes and return the first user sent mime that
  # matches the order array.
  #
  def negotiate_mime(order)
    formats.each do |priority|
      if priority == Mime::ALL
        return order.first
      elsif order.include?(priority)
        return priority
      end
    end

    order.include?(Mime::ALL) ? formats.first : nil
  end


end