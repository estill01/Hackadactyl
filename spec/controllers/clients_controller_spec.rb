require 'spec_helper'

describe ClientsController do

  describe "POST 'create'" do

    context "Successful" do

      it "should create a client" do
        lambda do
          post_create
        end.should change(Client, :count).by(1)
      end

      it "should redirect to account creation page" do
        post_create
        response.should redirect_to(create_account_path(Client.first.account_token))
      end

      it "should send a welcome email" do
        post_create
      end

    end

    context "unsuccessful" do

      it "should not create a client" do
        lambda do
          post_create(:first_name => nil)
        end.should_not change(Client, :count).by(1)
      end

      it "should render home page" do
        post_create(:first_name => nil)
        response.should render_template("home")
      end

      it "should flash a message" do
        post_create(:first_name => nil)
        flash[:notice].should_not be_nil
      end

    end

    def post_create(options = {})
      post :create, :client => Factory.build(:client).attributes.merge(options)
    end

  end

end
