require "factory_girl"
require ::Rails.root.to_s + "/spec/factories"
class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :first_name,       :limit => 50
      t.string :last_name,        :limit => 50
      t.string :username,         :limit => 20
      t.string :email,            :limit => 255
      t.string :hashed_password,  :limit => 40,  :default => "", :null => false
      t.string :salt,             :limit => 40,  :default => "", :null => false
      t.boolean :enabled,                        :default => true
      #Tokens
      t.string :remember_token,         :limit => 40
      t.datetime :remember_token_expires_at
      t.timestamps
    end
    add_index :users, :username
    add_index :users, :first_name
    add_index :users, :last_name
    add_index :users, :remember_token
    
    Factory(:user, :username => 'fotoverite', :password => "markie123", :password_confirmation => "markie123") if Rails.env == "development"
  end

  def self.down
    drop_table :users
  end
end
