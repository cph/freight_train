Feature: Form Elements
  
  @javascript
  Scenario: Creating all kinds of form elements
    Given I am on the Form Test page
    When I check "Checkbox" for the new form test
    And I fill in "Amount" with "32" for the new form test
    And I select "USD" for "Currency" for the new form test
    And I press "Create Form test"
    Then there should be 1 form test
    And I should see "$32.00 USD" in the 1st form test
    And the toggle should be on in the 1st form test
  
  @javascript
  Scenario: Updating all kinds of form elements
    Given I have the following form tests:
      | checkbox  | amount        | currency      |
      | 1         | 32.00         | USD           |
    And I am on the Form Test page
    When I click on the 1st form test
    And I uncheck "Checkbox" for the edited form test
    And I fill in "Amount" with "48" for the edited form test
    And I select "DKK" for "Currency" for the edited form test
    And I press "Save"
    Then I should see "$48.00 DKK" in the 1st form test
    And the toggle should be off in the 1st form test
