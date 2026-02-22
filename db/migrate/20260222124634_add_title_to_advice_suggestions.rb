class AddTitleToAdviceSuggestions < ActiveRecord::Migration[8.0]
  def change
    add_column :advice_suggestions, :title, :string
  end
end
