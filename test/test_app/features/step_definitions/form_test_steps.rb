Given /^I have the following form tests:$/ do |table|
  table.hashes.each do |hash|
    FormTest.create!(hash)
  end
end

Then /^there should be (\d+) form test$/ do |form_tests_count|
  with_scope('#form_tests') do
    assert_equal form_tests_count.to_i, all('.form_test').length
  end
end

Then /^I should see "([^"]*)" in the (\d+)st form test$/ do |content, n|
  with_scope('#form_tests') do
    assert all('.form_test')[n.to_i - 1].has_content?(content)
  end
end

Then /^the toggle should be (on|off) in the (\d+)(?:st|nd|rd|th) form test$/ do |state, n|
  with_scope('#form_tests') do
    case state
    when 'on';  assert_equal 'toggle yes',  all('.form_test .toggle')[n.to_i - 1]['class']
    when 'off'; assert_equal 'toggle no',   all('.form_test .toggle')[n.to_i - 1]['class']
    end
  end
end

When /^I click on the (\d+)(?:st|nd|rd|th) form test$/ do |n|
  all('.form_test')[n.to_i - 1].click
end



When /^I fill in "Amount" with "([^"]*)" for the (new|edited) form test$/ do |value, edited_or_new|
  selector = (edited_or_new == "edited" ? "#edit_row.form_test" : "#new_form_test")
  with_scope(selector) do
    fill_in("form_test[money][amount]", :with => value)
  end
end

When /^I select "([^"]*)" for "Currency" for the (new|edited) form test$/ do |value, edited_or_new|
  selector = (edited_or_new == "edited" ? "#edit_row.form_test" : "#new_form_test")
  with_scope(selector) do
    select(value, :from => "form_test[money][currency]")
  end
end
