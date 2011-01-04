class CreateClients < ActiveRecord::Migration
  def self.up
    create_table :clients do |t|
      t.string :first_name, :last_name, :email, :cell, :emergency_contact, :how_they_heard, :hashed_password, :salt
      t.string :country, :state, :city, :address, :suite
      t.string :account_token
      t.integer :education
      t.integer :students
      t.boolean :rich
      t.timestamps
    end
  end

  def self.down
    drop_table :clients
  end
end
