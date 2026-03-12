class AddViewsCountToAdvices < ActiveRecord::Migration[8.0]
  def change
    add_column :advices, :views_count, :integer, null: false, default: 0
    add_index :advices, :views_count
  end
end
