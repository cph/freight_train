class Hour < ActiveRecord::Base
  
  belongs_to :to_do_item
  
end
