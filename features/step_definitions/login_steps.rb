Given /^the user fotoverite$/ do 
  @user = Factory(:user, :username => "fotoverite", :password => "anicepassword", :password_confirmation => "anicepassword", :email => 'fotoverite@gmail.com')
end

Given /^the disabled user fotoverite$/ do 
  @user = Factory(:user, :username => "fotoverite", :password => "anicepassword", :password_confirmation => "anicepassword", :email => 'fotoverite@gmail.com', :enabled => false)
end
