class FavoritesController < ApplicationController
  before_action :authenticate_user!

  def index
    @advices = current_user.favorite_advices.includes(:category).order(created_at: :desc)
  end

  def create
    advice = Advice.find(params[:favorite][:advice_id])
    favorite = current_user.favorites.find_by(advice: advice)

    if favorite
      favorite.destroy
      render json: { status: "removed" }
    else
      current_user.favorites.create!(advice: advice)
      render json: { status: "added" }
    end
  end

  def destroy
    current_user.favorites.find(params[:id]).destroy!
    head :ok
  end
end
