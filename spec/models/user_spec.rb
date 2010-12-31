require 'spec_helper'


describe User do

  it "should be able to call a User's full name" do
    Factory(:user).full_name.should == "John Doe"
  end

  it "should create salt and salt password on create" do
    Time.stub!(:now).and_return(Time.parse('1/2/3'))
    @User= Factory(:user, :username => "JimAkAStatic")
    @User.salt.should == "5c7a04dfa3c8b5f2d851dac39b2f0b299afa6bb6"
    @User.hashed_password.should == "d26ead57d1c9cf42fd04b4448e574f450c93621b"
  end

  it "should call nil on password attribute after create" do
    @User= Factory(:user)
    @User.password.should be_nil
  end


  describe "authentication" do

    before(:each) do
      @User= Factory(:user)
    end

    it "should be able to autheticate a User if a created username and correct password is given" do
      User.authenticate(@User.username, "password").should == @User      
    end

    it "should not autheticate a User if a username does not exist" do
      User.authenticate("fake_username", "password").should be_false
    end

    it "should not autheticate a User if a created username and incorrect password is given" do
      User.authenticate(@User.username, "incorrect").should == false
    end


    it "should be able to authenticate a password" do
      @User.is_authenticated?("password").should be_true
      @User.is_authenticated?("incorrect").should be_false
    end

  end

  describe "trying to reset a User's password" do

    before(:each) do
      @User= Factory(:user)
    end

    it "should change password if with a new password and a password confirmation" do
      lambda do
        @User.try_to_reset_password("3dgjms", "3dgjms")
      end.should change(@User, :hashed_password)
    end

    it "should not change password with a new password and a different confirmation" do
      @User.should_not_receive(:update_attributes)
      @User.try_to_reset_password("password", "differnt").should be_false
    end

    it "should not allow nil to be set for the password" do
      @User.try_to_reset_password(nil, nil).should be_false
    end

    it "should not allow giberish to be set for the password"

  end

  describe "remember_token? method" do

    it "should return false if there is no remember_token" do
      Factory(:user).remember_token?.should be_false
    end

    it "should return false if there is a remember_token that has expired" do
      Factory(:user, :remember_token => "abc", :remember_token_expires_at => nil ).remember_token?.should be_false
    end

    it "should return false if there is a remember_token that has expired" do
      Factory(:user, :remember_token => "abc", :remember_token_expires_at => Time.now - 1).remember_token?.should be_false
    end

    it "should return ture if there is a non expired remember_token" do
      Factory(:user, :remember_token => "abc", :remember_token_expires_at => Time.now + 1).remember_token?.should be_true
    end

  end

  describe "remember_me method" do

    it "should call remember_me_for with 2.weeks" do
      @User = Factory(:user)
      @User.should_receive(:remember_me_for).with(2.weeks)
      @User.remember_me
    end

  end

  describe "remember_me_for method" do

    it "should call remember_me_until with time from input" do
      @User = Factory(:user)
      @User.should_receive(:remember_me_until)
      @User.remember_me_for(2.weeks)
    end

  end

  describe "remember_me_until method" do

    it "should create a remember_token" do
      @User = Factory(:user)
      User.stub!(:create_token).and_return("ABC")
      lambda do
        @User.remember_me_until(Time.now + 3000)
      end.should change(@User, :remember_token).from(nil).to("ABC")
    end

    it "should set the expiration_date for token to designated time" do
      @User = Factory(:user)
      @time = Time.now + 3000
      lambda do
        @User.remember_me_until(@time)
      end.should change(@User, :remember_token_expires_at).from(nil).to(@time)
    end

  end

  describe "refresh_token method" do

    it "should create a new remember_token" do
      @User = Factory(:user, :remember_token => "abc", :remember_token_expires_at => Time.now + 30000)
      User.stub!(:create_token).and_return("DEF")
      lambda do
        @User.refresh_token
      end.should change(@User, :remember_token).from("abc").to("DEF")
    end

    it "should keep the expiration_date" do
      @time = Time.now + 3000
      @User = Factory(:user, :remember_token => "abc", :remember_token_expires_at => @time)
      lambda do
        @User.refresh_token
      end.should_not change(@User, :remember_token_expires_at)
    end

    it "should not create a new remember_token if expired" do
      @User = Factory(:user, :remember_token => "abc", :remember_token_expires_at => Time.now - 30000)
      lambda do
        @User.refresh_token
      end.should_not change(@User, :remember_token)
    end

  end

  describe "forget_me method" do

    it "should delete the remember_token" do
      @User = Factory(:user, :remember_token => "abc", :remember_token_expires_at => Time.now - 30000)
      lambda do
        @User.forget_me
      end.should change(@User, :remember_token).from("abc").to(nil)
    end

    it "should delete the remember_token_expires_at" do
      @time = Time.now + 3000
      @User = Factory(:user, :remember_token => "abc", :remember_token_expires_at => @time)
      lambda do
        @User.forget_me
      end.should change(@User, :remember_token_expires_at).from(@time).to(nil)
    end

  end

  describe "updating" do

    before(:each) do
      @mock_user = Factory(:user)
    end

    it "should allow updating of fields that are not password or email" do
      lambda do
        @mock_user.update_attributes(:first_name => "matthew")
      end.should change(@mock_user, :first_name).from("John").to("matthew")
    end

    it "should not allow updating of email without confirmation and previous password" do
      @mock_user.update_attributes(:email => "matthew@aol.com")
      @mock_user.valid?.should be_false
      @mock_user.errors[:email_confirmation].should_not be_nil
    end

    it "should not allow updating of email without confirmation" do
      @mock_user.update_attributes(:email => "matthew@aol.com", :previous_password => "markie")
      @mock_user.valid?.should be_false
      @mock_user.errors[:email_confirmation].should_not be_nil
    end

    it "should not allow updating of email without previous_password" do
      @mock_user.update_attributes(:email => "matthew@aol.com", :email => "matthew@aol.com")
      @mock_user.valid?.should be_false
      @mock_user.errors[:email_confirmation].should_not be_nil
    end

    it "should not allow updating of email whith incorrect previous_password" do
      @mock_user.update_attributes(:email => "matthew@aol.com", :email_confirmation => "matthew@aol.com", :previous_password => "markie")
      @mock_user.valid?.should be_false
      @mock_user.errors[:previous_password].should_not be_nil
    end

    it "should allow updating of email with correct previous_password and confirmation" do
      lambda do
        @mock_user.update_attributes(:email => "matthew@aol.com", :email => "matthew@aol.com", :previous_password => "password")
      end.should change(@mock_user, :email)
    end

    it "should allow updating of password without previous_password" do
      @mock_user.update_attributes(:password => "password", :password_confirmation => "password")
      @mock_user.valid?.should be_true
    end

    it "should allow updating of password whith incorrect previous_password" do
      @mock_user.update_attributes(:password => "salve", :password_confirmation => "salve", :previous_password => "markie")
      @mock_user.valid?.should be_false
      @mock_user.errors[:previous_password].should_not be_nil
    end

    it "should allow updating of email with correct previous_password and confirmation" do
      @mock_user = Factory(:user)
      lambda do
        @mock_user.update_attributes(:password => "salve", :password_confirmation => "salve", :previous_password => "password")
      end.should change(@mock_user, :hashed_password)
    end

  end

  describe "validation" do

    it "should be invalid without a first_name" do
      @User = Factory.build(:user, :first_name => "")
      @User.valid?.should be_false
      @User.errors[:first_name].should_not be_nil
    end

    it "should be invalid without a last_name" do
      @User = Factory.build(:user, :last_name => "")
      @User.valid?.should be_false
      @User.errors[:last_name].should_not be_nil
    end

    it "should be invalid without a username" do
      @User = Factory.build(:user, :username => "")
      @User.valid?.should be_false
      @User.errors[:username].should_not be_nil
    end

    it "should be invalid without a email" do
      @User = Factory.build(:user, :email => "")
      @User.valid?.should be_false
      @User.errors[:email].should_not be_nil
    end

    it "should be invalid without a password" do
      @User = Factory.build(:user, :password => "")
      @User.valid?.should be_false
      @User.errors[:password].should_not be_nil
    end

    it "should be invalid with a first_name greater then 50" do
      @User = Factory.build(:user, :first_name => "c" * 51)
      @User.valid?.should be_false
      @User.errors[:first_name].should_not be_nil
    end

    it "should be invalid with a last_name greater then 50" do
      @User = Factory.build(:user, :last_name => "c" * 51)
      @User.valid?.should be_false
      @User.errors[:last_name].should_not be_nil
    end

    it "should be invalid with a email greater then 255" do
      @User = Factory.build(:user, :email => "c" * 256)
      @User.valid?.should be_false
      @User.errors[:email].should_not be_nil
    end

    it "should be invalid with a username greater then 25" do
      @User = Factory.build(:user, :username => "c" * 26)
      @User.valid?.should be_false
      @User.errors[:username].should_not be_nil
    end


    it "should be invalid without a unique username" do
      #Validate uniqueness must hit the database
      @mock_user = Factory(:user, :username => 'fotoverite')
      lambda do
        Factory(:user, :username => @mock_user.username)
      end.should raise_error(ActiveRecord::RecordInvalid)
    end

    it "Uniqueness should not be case sensitive" do
      #Validate uniqueness must hit the database
      @mock_user = Factory(:user, :username => 'fotoverite')
      lambda do
        Factory(:user, :username => "FotoVerite")
      end.should raise_error(ActiveRecord::RecordInvalid)
    end

    it "should be invalid without a unique email scoped by role_id" do
      #Validate uniqueness must hit the database
      @mock_user = Factory(:user)
      lambda do
        Factory(:user, :email => @mock_user.email)
      end.should raise_error(ActiveRecord::RecordInvalid)
    end

    it "should be valid without a unique email with a different role_id" do
      #Validate uniqueness must hit the database
      @mock_user = Factory(:user)
      lambda do
        Factory(:contact, :email => @mock_user.email)
      end.should_not raise_error(ActiveRecord::RecordInvalid)
    end

  end

end

