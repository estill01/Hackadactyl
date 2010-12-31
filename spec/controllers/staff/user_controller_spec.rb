require 'spec_helper'

describe Staff::UsersController do

  describe "GET 'index'" do

    before(:each) do
      @user =  Factory(:admin)
      login_as(@user)
    end

    it "should assign and paginate found users to users" do
      get_index
      assigns[:users].should == [@user]
    end

    it "should be a success" do
      get_index
      response.should be_success
    end

    it "should render the listing index" do
      get_index
      response.should render_template("index")
    end

    def get_index
      get :index
    end
  end

  describe "GET 'new'" do

    before(:each) do
      admin_login
    end

    it "should create a new user and assign it to @user" do
      @user1 = User.new
      User.stub!(:new).and_return(@user1)
      get_new
      assigns[:user].should == @user1
    end

    it "should be a success" do
      get_new
      response.should be_success
    end

    it "should render the template new" do
      get_new
      response.should render_template(:new)
    end

    def get_new
      get :new
    end

  end

  describe "GET 'show'" do

    before(:each) do
      admin_login
      @user = Factory(:admin)
    end

    it "should find the designated user and assign it to user" do
      get_show
      assigns[:user].should == @user
    end

    it "should be a success" do
      get_show
      response.should be_success
    end

    it "should render the template new" do
      get_show
      response.should render_template(:show)
    end

    def get_show
      get :show, :id => @user.id
    end

  end

  describe "POST 'create'" do

    before(:each) do
      admin_login
    end

    context "successful" do

      it "should create a new user" do
        lambda do
          post_create
        end.should change(User, :count).by(1)
      end

      it "should flash a notice" do
        post_create
        flash[:notice].should_not be_nil
      end

      it "should redirect_to staff_users_path" do
        post_create
        response.should redirect_to(staff_users_path)
      end

    end

    context "unsuccessful" do

      it "should render template new" do
        post_create( :username => nil)
        response.should render_template(:new)
      end

    end

    def post_create(options = {})
      post :create, :user => {:first_name => "Matthew", :last_name => "Bergman", :username => 'fotoverite', :password => "password", :password_confirmation => 'password', :email => "dosomething@dosomething.com"}.merge(options)
    end

  end

  describe "GET 'edit'" do

    before(:each) do
      admin_login
      @user = Factory(:admin)
    end

    it "should assign found user to @user1" do
      get_edit
      assigns[:user].should == @user
    end

    it "should be a success" do
      get_edit
      response.should be_success
    end

    it "should render the edit template" do
      get_edit
      response.should render_template("edit")
    end

    def get_edit
      get :edit, :id => @user.id
    end
  end

  describe "PUT 'update'" do

    before(:each) do
      admin_login
      Factory(:admin)
      @user = Factory(:admin)
    end

    context "successful" do

      it "should update the users's attributes" do
        put_update
        @user.reload.first_name.should == "Columbus"
      end

      it "should flash a notice" do
        put_update
        flash[:notice].should_not be_nil
      end

      it "should redirect to staff_users_path" do
        put_update
        response.should redirect_to(staff_users_path)
      end

    end

    context "unsuccessful" do

      it "should render template new" do
        put_update(:username => nil)
        response.should render_template(:edit)
      end

    end

    def put_update(options = {})
      put :update, :id => @user.id, :user => {:first_name => "Columbus"}.merge(options)
    end
  end


  describe "GET 'delete'" do

    before(:each) do
      admin_login
      @user1 = Factory(:admin)
    end

    it "should assign found user to @user1" do
      get_delete
      assigns[:user].should == @user1
    end

    it "should be a success" do
      get_delete
      response.should be_success
    end

    it "should render the delete template" do
      get_delete
      response.should render_template("delete")
    end

    def get_delete
      #still need to test for layout false. Seems very complicated and not mission critical
      get :delete, :id => @user1.id
    end
  end

  describe "DELETE 'destroy'" do

    before(:each) do
      admin_login
      @user = Factory(:admin)
    end

    it "should delete the image" do
      lambda do
        delete_destroy
      end.should change(User, :count).by(-1)
    end

    it "should flash a notice" do
      delete_destroy
      flash[:notice].should_not be_nil
    end


    it "should redirect to staff_users_path" do
      delete_destroy
      response.should redirect_to(staff_users_path)
    end

    def delete_destroy
      #still need to test for layout false. Seems very complicated and not mission critical
      delete :destroy, :id => @user.id
    end

  end
end
