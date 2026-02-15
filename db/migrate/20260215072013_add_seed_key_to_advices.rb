class AddSeedKeyToAdvices < ActiveRecord::Migration[7.1]
  def change
    add_column :advices, :seed_key, :string
    add_index :advices,
              :seed_key,
              unique: true,
              where: "seed_key IS NOT NULL"
  end
end
