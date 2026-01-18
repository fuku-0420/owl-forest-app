class CreateAdvices < ActiveRecord::Migration[8.0]
  def change
    create_table :advices do |t|
      t.references :category, null: false, foreign_key: true
      t.string :title
      t.text :body

      t.timestamps
    end
  end
end
