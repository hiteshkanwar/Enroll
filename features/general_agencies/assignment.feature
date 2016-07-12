@wip
Feature: Broker Assigns a General Agency to an Employer

  Scenario: A Broker Assigns a General Agency to an Employer
    Given a general agency, approved, confirmed, exists
    And a broker exists
    And an employer exists
    When the broker visits their Employers page
    And selects the general agency from dropdown for the employer
    Then the employer will be assigned that general agency
