module Mime


  def self.[](type)
    return type if type.is_a?(Type)
    Type.lookup_by_extension(type.to_s)
  end


end