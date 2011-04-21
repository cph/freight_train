Feature: Index

  Scenario: Listing items
    Given I have the following to-do items:
      | description                                         |
      | Write features to spec FreightTrain's functionality |
      | Refactor FreightTrain to be library agnostic        |
      | Drink a beer                                        |
    When I am on the To Do Items page
    Then I should see "Write features to spec FreightTrain's functionality"
    And I should see "Drink a beer"
