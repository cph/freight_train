When /^(?:|I )click "([^"]*)"(?: within "([^"]*)")?$/ do |id, selector|
  with_scope(selector) do
    find(id).trigger(:click)
  end
end