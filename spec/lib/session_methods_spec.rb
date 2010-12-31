require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

include SessionMethods

def action_name() end

describe ApplicationController, :behaviour_type => :controller do
  include RSpec::Rails::ControllerExampleGroup

  before do
    # FIXME -- sessions controller not testing xml logins
    # We don't have xml logins? Matt
    stub!(:authenticate_with_http_basic).and_return nil
  end

  #This doesn't test anything!
  describe "saving info to session" do

    before do
      @user = Factory(:admin)
      login_as(@user)
      stub!(:reset_session)
    end

    it "should save username to session" do
      session[:username].should == @user.username
    end

    it "should save id to session" do
      session[:id].should == @user.id
    end

  end

  describe "logout_killing_session!" do
    before do
      @user = Factory(:admin)
      login_as(@user)
      stub!(:reset_session)
    end

    it 'resets the session' do
      should_receive(:reset_session)
      logout_killing_session!
    end
    it 'kills my auth_token cookie' do
      should_receive(:kill_remember_cookie!)
      logout_killing_session!
    end
    it 'nils the current user' do
      logout_killing_session!
      current_user.should be_nil
    end
    it 'kills :id session' do
      session.stub!(:[]=)
      session.should_receive(:[]=).with(:id, nil).at_least(:once)
      logout_killing_session!
    end
    it 'forgets me' do
      current_user.remember_me
      current_user.remember_token.should_not be_nil
      current_user.remember_token_expires_at.should_not be_nil
      User.find(@user.id).remember_token.should_not be_nil
      User.find(@user.id).remember_token_expires_at.should_not be_nil
      logout_killing_session!
      User.find(@user.id).remember_token.should be_nil
      User.find(@user.id
                ).remember_token_expires_at.should be_nil
    end
  end

  describe "logout_keeping_session!" do
    before do
      @user = Factory(:admin)
      login_as(@user)
      stub!(:reset_session)
    end
    it 'does not reset the session' do
      should_not_receive(:reset_session)
      logout_keeping_session!
    end
    it 'kills my auth_token cookie' do
      should_receive(:kill_remember_cookie!)
      logout_keeping_session!
    end
    it 'nils the current user' do
      logout_keeping_session!
      current_user.should be_nil
    end
    it 'kills :id session' do
      session.stub!(:[]=)
      session.should_receive(:[]=).with(:id, nil).at_least(:once)
      session.should_receive(:[]=).with(:username, nil).at_least(:once)
      session.should_receive(:[]=).with(:class, nil).at_least(:once)
      logout_keeping_session!
    end
    it 'forgets me' do
      current_user.remember_me
      current_user.remember_token.should_not be_nil
      current_user.remember_token_expires_at.should_not be_nil
      User.find(@user.id).remember_token.should_not be_nil
      User.find(@user.id).remember_token_expires_at.should_not be_nil
      logout_keeping_session!
      User.find(@user.id).remember_token.should be_nil
      User.find(@user.id).remember_token_expires_at.should be_nil
    end
  end

  #
  # Cookie Login
  #
  describe "Logging in by cookie" do
    def set_remember_token token, time
      @user[:remember_token]            = token;
      @user[:remember_token_expires_at] = time
      @user.save!
    end
    before do
      @user = Factory(:admin)
      @user = User.first
      set_remember_token 'hello!', 5.minutes.from_now
      session[:id] = nil
    end
    it 'logs in with cookie' do
      stub!(:cookies).and_return({ :auth_token => 'hello!', :class => "User" })
      logged_in?.should be_true
    end

    it 'fails cookie login with bad cookie' do
      should_receive(:cookies).at_least(:once).and_return({ :auth_token => 'i_haxxor_joo', :class => "User" })
      logged_in?.should_not be_true
    end

    it 'fails cookie login with no cookie' do
      set_remember_token nil, nil
      should_receive(:cookies).at_least(:once).and_return({ })
      logged_in?.should_not be_true
    end

    it 'fails expired cookie login' do
      set_remember_token 'hello!', 5.minutes.ago
      stub!(:cookies).and_return({ :auth_token => 'hello!' , :class => "User" })
      logged_in?.should_not be_true
    end
  end

end
