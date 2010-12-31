require 'spec_helper'

describe Staff::AccessController do

  if false
    it "before filter should include confirm_staff_area_open" do
      @controller.should have_filter(:confirm_staff_area_open)
    end

    it "before filter should include require_low_level_access" do
      @controller.should have_filter(:require_any_level_access).before(
        [:menu, :logout, :edit_password]
      )
    end
  end

  describe "GET 'new'" do

    it "should be a success" do
      get_new
      response.should be_success
    end

    it "should render template new" do
      get_new
      response.should render_template(:new)
    end


    def get_new
      get :new
    end

  end

  describe "GET 'menu'" do

    before(:each) do
      admin_login
    end

    it "should be a success" do
      get_menu
      response.should be_success
    end

    it "should render template menu" do
      get_menu
      response.should render_template(:menu)
    end


    def get_menu
      get :menu
    end

  end

  describe "POST 'create'" do

    before(:each) do
      @user = Factory(:admin)
    end

    it "should call authenticate on User with the params given" do
      User.should_receive(:authenticate).with(@user.username, "password").and_return(@user)
      post_create
    end

    it "should log in the user" do
      post_create
      session[:id].should == @user.id
      session[:username].should == @user.username
    end

    it "should flash a message" do
      post_create
      flash[:notice].should_not be_nil
    end

    it "should redirect menu" do
      post_create
      response.should redirect_to(staff_menu_path)
    end

    it "should flash notice if the user is not found" do
      post :create, :username => @user.username, :password => "bad_password"
      flash[:error].should_not be_nil
    end

    it "should set navigation as hidden if no user is found" do
      post :create, :username => @user.username, :password => "bad_password"
      assigns[:hide_navigation].should be_true
    end

    it "should set navigation as hidden if no password is given" do
      post :create, :username => @user.username
      assigns[:hide_navigation].should be_true
    end

    it "should set navigation as hidden if no username is given" do
      post :create, :username => nil
      assigns[:hide_navigation].should be_true
    end


    def post_create
      post :create, :username => @user.username, :password => "password"
    end

  end

  describe "GET 'logout'" do

    before(:each) do
      admin_login
    end

    it "should log the user out" do
      session[:id].should == @user.id
      delete_destroy
      session[:id].should == nil
    end

    it "should redirect to the login_path" do
      delete_destroy
      response.should redirect_to(staff_login_path)
    end

    def delete_destroy
      delete :destroy
    end

  end

  #PASSWORD METHODS

  describe "GET 'forgot_password'" do

    it "should be a success" do
      get_forgot_password
      response.should be_success
    end

    it "should set hide_navigation to true" do
      get_forgot_password
      assigns[:hide_navigation].should be_true
    end

    it "should render the forgot_password template" do
      get_forgot_password
      response.should render_template("forgot_password")
    end

    def get_forgot_password
      get :forgot_password
    end

  end

  describe "POST 'send_new_password'" do

    before(:each) do
      @user = Factory(:admin)
    end

    context "with actual username" do

      it "should call try_to_email_password on user" do
        User.stub!(:where).and_return([@user])
        @user.should_receive(:delay).and_return(@user)
        post_send_new_password(@user.username)
      end

      it "should flash notice" do
        post_send_new_password(@user.username)
        flash[:notice].should_not be_nil
      end

      it "should redirect to login page" do
        post_send_new_password(@user.username)
        response.should redirect_to(staff_login_path)
      end

    end

    context "with bad username" do

      it "should set hide_navigation to true" do
        post_send_new_password('bad')
        assigns :hide_navigation.should be_true
      end

      it "should flash notice" do
        post_send_new_password('bad')
        flash[:notice].should_not be_nil
      end

      it "should render forgot password page" do
        post_send_new_password("bad")
        response.should render_template("forgot_password")
      end

    end

    def post_send_new_password(username)
      get :send_new_password, :username => username
    end

  end

end
