When /^(?:|I )click "([^"]*)"(?: within "([^"]*)")?$/ do |id, selector|
  with_scope(selector) do
    find(id).trigger(:click)
  end
end



When /^I check "([^"]*)" for the (new|edited) (.*)$/ do |field, edited_or_new, klass|
  klass = klass.downcase.gsub(/ /, '_')
  selector = (edited_or_new == "edited" ? "#edit_row.#{klass}" : "#new_#{klass}")
  with_scope(selector) do
    check("#{klass}[#{field.downcase}]")
  end
end

When /^I uncheck "([^"]*)" for the (new|edited) (.*)$/ do |field, edited_or_new, klass|
  klass = klass.downcase.gsub(/ /, '_')
  selector = (edited_or_new == "edited" ? "#edit_row.#{klass}" : "#new_#{klass}")
  with_scope(selector) do
    uncheck("#{klass}[#{field.downcase}]")
  end
end



# When /^I fill in "([^"]*)" with "([^"]*)" for the (new|edited) (.*)$/ do |field, value, edited_or_new, klass|
#   klass = klass.downcase.gsub(/ /, '_')
#   selector = (edited_or_new == "edited" ? "#edit_row.#{klass}" : "#new_#{klass}")
#   with_scope(selector) do
#     fill_in("#{klass}[#{field.downcase}]", :with => value)
#   end
# end
#
#
#
# When /^I select "([^"]*)" for "([^"]*)" for the (new|edited) (.*)$/ do |value, field, edited_or_new, klass|
#   klass = klass.downcase.gsub(/ /, '_')
#   selector = (edited_or_new == "edited" ? "#edit_row.#{klass}" : "#new_#{klass}")
#   with_scope(selector) do
#     select(value, :from => "#{klass}[#{field.downcase}]")
#   end
# end
#
