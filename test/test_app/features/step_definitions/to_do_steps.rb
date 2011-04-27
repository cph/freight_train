Given /^I have the following to\-do items:$/ do |table|
  table.hashes.each do |hash|
    ToDoItem.create!(hash)
  end
end


# Extended Web Steps

When /^I click on the to\-do item "([^"]*)"$/ do |description|
  to_do_item = ToDoItem.find_by_description(description)
  selector = "#to_do_item_#{to_do_item.id}"
  find(selector).click
end

When /^I follow "([^"]*)" within the to\-do item "([^"]*)"$/ do |link, description|
  to_do_item = ToDoItem.find_by_description(description)
  with_scope("#to_do_item_#{to_do_item.id}") do
    click_link(link)
  end
end

Then /^there should be (\d+) To Do Items?$/ do |n|
  assert_equal n.to_i, ToDoItem.count
end
