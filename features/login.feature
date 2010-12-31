Feature: Logging In
  In order to use the staff area
  A user must be able to log in if they have an account
	
	Scenario: Logging in with an account
	  Given the user fotoverite
  	And I go to the staff login page
  	When I fill in the following:
   	 | username | fotoverite    |
   	 | password | anicepassword |
   	And I press "Log In"
   	Then I should be on the staff menu page
 	
 	Scenario: Logging in with an account with wrong password
  	Given the user fotoverite
  	And I go to the staff login page
  	When I fill in the following:
   	 | username | fotoverite  |
   	 | password | badpassword |
   	And I press "Log In"
   	Then I should be on the staff access page
   	And I should see "Please try again."

 	
	
