class CreateChildren < ActiveRecord::Migration
  def self.up
    create_table :children do |t|
      t.string :first_name, :last_name, :age, :school
      t.boolean :female, :laptop
      t.text :interest_in_tech, :goals
      t.references :client
      t.timestamps
    end
  end

  def self.down
    drop_table :children
  end
end
