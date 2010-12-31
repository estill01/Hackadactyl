require 'spec_helper'

describe ApplicationController do
  include RSpec::Rails::ControllerExampleGroup

  def has_access
    response.should be_success
  end

  def has_no_access
    flash[:notice].should == "Insufficient access privileges."
    response.should be_redirect
  end
  #creating a mock class to test various before_filter
  controller do
    before_filter :confirm_staff_area_open, :only => :staff_area_open

    before_filter :confirm_staff_logged_in, :only => :staff_logged_in
    before_filter :confirm_not_logged_in, :only => :confirm_user_not_logged_in


    def staff_logged_in
      render :text => "foo"
    end

    def confirm_user_not_logged_in
      render :text => "foo"
    end

    def staff_area_open
      render :text => "foo"
    end

    def remember_page_param
      remember_page
      render :text => "foo"
      @page = params[:page]
    end

    def retain_page
      remember_page
      render :text => "foo"
    end

    def error_500
      render_500
    end

    def authenticate
      @authenticated = http_authenticate
      render :text => "foo" if @authenticated == true
    end

    def desired
      redirect_to_desired_url(url_for(root_path))
    end

  end

  before do
    @orig_routes, @routes = @routes, ActionDispatch::Routing::RouteSet.new
    @routes.draw {
      root :to => 'static_pages#show'
      resources :stub_resources do
        collection do
          get :desired
          get :staff_logged_in
          get :confirm_user_not_logged_in
          get :error_500
          get :render_404
        end
      end
    }
  end

  after do
    @routes = @orig_routes
  end

  describe "staff_logged_in" do

    context "user logged in" do

      it "should return true" do
        admin_login
        get :staff_logged_in
        response.should be_success
      end

    end

    if false
      #Basically rspec2 has a lot of problem with dummy classes. Still working on fixing this
      context "user not logged in" do

        it "should redirect" do
          get :staff_logged_in
          response.should be_redirect
        end

        it "should flash a notice" do
          get :staff_logged_in
          flash[:notice].should_not be_nil
        end

        it "should redirect to login_path if no url is given" do
          get :staff_logged_in
          response.should redirect_to(login_path)
        end

      end

    end
  end

  describe "confirm_not_logged_in" do

    context "user not logged in" do

      it "should return true" do
        get :confirm_user_not_logged_in
        response.should be_success
      end

    end

    context "user logged in" do

      it "should redirect" do
        admin_login
        get :confirm_user_not_logged_in
        response.should be_redirect
      end

      it "should flash a notice" do
        admin_login
        get :confirm_user_not_logged_in
        flash[:notice].should_not be_nil
      end

    end

  end

  describe "redirect_to_desired_url" do

    it "redirect to the session desired_url" do
      session[:desired_url] = "root"
      get :desired
      response.should redirect_to("root")
    end

    it "redirect to the specified default url if no desired url is given" do
      get :desired
      response.should redirect_to(root_path)
    end

  end

  describe "get_nice_password" do

    it "should call NicePassword with :length => 12, :words => 2, :digits => 2" do
      NicePassword.should_receive(:new).with(:length => 12, :words => 2, :digits => 2)
      controller.get_nice_password
    end

    it "should return a nice password" do
      NicePassword.stub!(:new).and_return("ANicePassword")
      controller.get_nice_password.should == "ANicePassword"
    end

  end

  describe "render_500" do

    it "should render a 500 error" do
      get :error_500
      response.should be_error
    end

  end

  describe "render_404" do

    it "should render a 404 error" do
      get :render_404
      response.status.should == 404
    end

  end

end
