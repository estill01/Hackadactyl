Feature: Remembering Forgotten Password
  In order to use the staff area
  A user must be able to get a new password if their old one is forgotten
  
  Scenario: Getting a reset token with an enabled account
    Given the user fotoverite
    When I go to the staff login page
    And I follow "Forgot my password"
    Then I should be on the staff forgot password page
    When I fill in "username" with "fotoverite"
    And press "Reset My Password"
    And "fotoverite@gmail.com" should receive an email with subject "Password Reset"
    When I open the email
    Then I should see "ANicePassword" in the email body
    
  Scenario: Getting a reset token with an disabled account
    Given the disabled user fotoverite
    When I go to the staff login page
    And I follow "Forgot my password"
    Then I should be on the staff forgot password page
    When I fill in "username" with "fotoverite"
    And press "Reset My Password"
    Then I should see "Username not found"
