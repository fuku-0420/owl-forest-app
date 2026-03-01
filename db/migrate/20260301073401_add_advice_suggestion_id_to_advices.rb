class AddAdviceSuggestionIdToAdvices < ActiveRecord::Migration[8.0]
  def change
    add_reference :advices, :advice_suggestion, null: true, foreign_key: true
  end
end
