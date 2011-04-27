class FormTest < ActiveRecord::Base
  
  composed_of :money, :class_name => "Money", :mapping => %w(amount currency)
  
end
