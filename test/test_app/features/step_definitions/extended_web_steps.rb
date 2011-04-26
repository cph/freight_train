When /^(?:|I )click "([^"]*)"(?: within "([^"]*)")?$/ do |id, selector|
  with_scope(selector) do
    find(id).trigger(:click)
  end
end

When /^I fill in the "([^"]*)" of the edited item with "([^"]*)"$/ do |field, new_description|
  with_scope("#edit_row.to_do_items") do
    fill_in(field, :with => new_description)
  end
end
