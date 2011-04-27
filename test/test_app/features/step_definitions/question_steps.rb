Given /^I have the following questions:$/ do |table|
  table.hashes.each do |hash|
    Question.create!(hash)
  end
end

Given /^the question "([^"]*)" has the following answers:$/ do |question, table|
  question = Question.find_by_text(question)
  table.hashes.each do |hash|
    question.answers.create(hash)
  end
end


# Extended Web Steps

Then /^the question "([^"]*)" should have (\d+) answers?$/ do |question, answers_count|
  question = Question.find_by_text(question)
  with_scope("#question_#{question.id}") do
    assert_equal answers_count.to_i, all('.answer').length
  end
  assert_equal answers_count.to_i, question.answers.count
end

Then /^the new question should have (\d+) answers?$/ do |answers_count|
  with_scope("#new_question") do
    assert_equal answers_count.to_i, all('.answer').length
  end
end

When /^I click on the question "([^"]*)"$/ do |question|
  question = Question.find_by_text(question)
  find("#question_#{question.id}").click
end

When /^I delete the (\d+)(?:st|rd|th) answer for the (edited|new) question$/ do |n, edited_or_new|
  selector = (edited_or_new == "edited" ? "#edit_row.question" : "#new_question")
  with_scope(selector) do
    all('a.delete-link')[n.to_i - 1].click
  end
end
