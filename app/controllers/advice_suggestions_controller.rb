class AdviceSuggestionsController < ApplicationController
  before_action :authenticate_user!

  def index
    base = current_user.advice_suggestions.includes(:category).order(created_at: :desc)

    @pending  = base.select(&:status_pending?)
    @approved = base.select(&:status_approved?)
    @rejected = base.reject { |s| s.status_pending? || s.status_approved? }
  end

  def new
    @advice_suggestion = current_user.advice_suggestions.new
  end

  def create
    @advice_suggestion = current_user.advice_suggestions.new(advice_suggestion_params)
    @advice_suggestion.status = :pending

    if @advice_suggestion.save
      redirect_to advice_suggestions_path, notice: "投稿を受け付けました！ありがとうございます。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def advice_suggestion_params
    params.require(:advice_suggestion).permit(:category_id, :body)
  end
end
