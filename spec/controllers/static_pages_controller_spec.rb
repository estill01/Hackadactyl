require 'spec_helper'

describe StaticPagesController do

  describe "GET 'show'" do

    context "without name" do

      it "should render root" do
        get :show
        response.should redirect_to root_path
      end

    end

    context "with a valid page" do

      for page in ['about']

        it "should be a success" do
          get_show(page)
          response.should be_success
        end

        it "should render the template 'static_pages/#{page}'" do
          get_show(page)
          response.should render_template("static_pages/#{page}")
        end

      end

      context "with an invalid page" do

        it "should render 4040" do
          get_show('junk')
          response.response_code.should == 404
        end

      end

    end

    def get_show(name)
      get :show, :name => name
    end

  end

end
