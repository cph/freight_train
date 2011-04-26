class ToDoItem < ActiveRecord::Base
  
  has_many :hours
  
  accepts_nested_attributes_for :hours
  
end
