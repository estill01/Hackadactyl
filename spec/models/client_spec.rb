require 'spec_helper'

describe Client do
  
  
  it "should create an account token" do
    @client = Factory(:client)
    @client.account_token.should_not be_nil
  end
  
  describe "validation" do

    it "should be valid with a first name, last name and email" do
      @client = Factory.build(:client)
      @client.valid?.should be_true
    end

    it "should be invalid without a first_name" do
      @client = Factory.build(:client, :first_name => "")
      @client.valid?.should be_false
      @client.errors[:first_name].should_not be_nil
    end

    it "should be invalid without a last_name" do
      @client = Factory.build(:client, :last_name => "")
      @client.valid?.should be_false
      @client.errors[:last_name].should_not be_nil
    end

    it "should be invalid without a email" do
      @client = Factory.build(:client, :email => "")
      @client.valid?.should be_false
      @client.errors[:email].should_not be_nil
    end

  end

end
