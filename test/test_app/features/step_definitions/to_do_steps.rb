Given /^I have the following to\-do items:$/ do |table|
  table.hashes.each do |hash|
    ToDoItem.create!(hash)
  end
end
