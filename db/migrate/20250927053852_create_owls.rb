class CreateOwls < ActiveRecord::Migration[8.0]
  def change
    create_table :owls do |t|
      t.string :name
      t.string :species
      t.integer :age
      t.string :habitat
      t.text :description

      t.timestamps
    end
  end
end
