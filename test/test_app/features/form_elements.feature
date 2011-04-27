Feature: Form Elements
  # 
  # @javascript
  # Scenario: Creating all kinds of form elements
  #   Given I am on the Questions page
  #   Then the new question should have 1 answer
  #   When I follow "Add"
  #   Then the new question should have 2 answers
  #   When I follow "Delete"
  #   Then the new question should have 1 answer
  # 
  # @javascript
  # Scenario: Updating all kinds of form elements
  #   Given I have the following questions:
  #     | text                        |
  #     | Which type of bear is best? |
  #   And the question "Which type of bear is best?" has the following answers:
  #     | text                        |
  #     | Grizzly                     |
  #     | Panda                       |
  #     | False, Brown Bear           |
  #   When I am on the Questions page
  #   And I click on the question "Which type of bear is best?"
  #   And I delete the 3rd answer for the edited question
  #   And I press "Save"
  #   Then the question "Which type of bear is best?" should have 2 answers
