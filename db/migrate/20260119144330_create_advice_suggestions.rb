class CreateAdviceSuggestions < ActiveRecord::Migration[8.0]
  def change
    create_table :advice_suggestions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.text :body
      t.integer :status

      t.timestamps
    end
  end
end
