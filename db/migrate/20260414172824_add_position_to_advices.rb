class AddPositionToAdvices < ActiveRecord::Migration[8.0]
  def change
    add_column :advices, :position, :integer
  end
end
