class Admin::AdviceSuggestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!

  def index
    @advice_suggestions = AdviceSuggestion
                            .status_pending
                            .includes(:user, :category)
                            .order(created_at: :asc)
  end

  def approve
    suggestion = AdviceSuggestion.find(params[:id])

    ActiveRecord::Base.transaction do
      suggestion.update!(status: :approved)

      Advice.create!(
        category_id: suggestion.category_id,
        title: suggestion.body.truncate(30),
        body: suggestion.body
      )
    end

    redirect_to admin_advice_suggestions_path, notice: "承認しました"
  end

  def reject
    suggestion = AdviceSuggestion.find(params[:id])
    suggestion.update!(status: :rejected)

    redirect_to admin_advice_suggestions_path, notice: "却下しました"
  end

  private

  def require_admin!
    redirect_to root_path, alert: "権限がありません" unless current_user.admin?
  end
end
