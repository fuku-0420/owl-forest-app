class Admin::AdviceSuggestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!

  def index
    base = AdviceSuggestion.includes(:user, :category)

    @pending  = base.status_pending.order(created_at: :asc)
    @approved = base.status_approved.order(created_at: :desc)
    @rejected = base.status_rejected.order(created_at: :desc)
  end

  def show
    @advice_suggestion = AdviceSuggestion.includes(:user, :category).find(params[:id])
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
    return if current_user&.admin?
    redirect_to root_path, alert: "権限がありません"
  end
end
