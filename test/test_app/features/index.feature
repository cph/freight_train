Feature: Index

  Scenario: Listing items
    Given I have the following to-do items:
      | description                                         |
      | Write features to spec FreightTrain's functionality |
      | Refactor FreightTrain to be library agnostic        |
    When I am on the To Do Items page
    Then I should see "Write features to spec FreightTrain's functionality"
    And I should see "Refactor FreightTrain to be library agnostic"

  @javascript
  Scenario: Creating an item
    Given I am on the To Do Items page
    And I should not see "Drink a beer"
    When I fill in "Description" with "Drink a beer"
    And I press "Create To do item"
    Then I should see "Drink a beer"
