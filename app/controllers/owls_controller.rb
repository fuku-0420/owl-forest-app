class OwlsController < ApplicationController
  def index
    @owls = Owl.all
    @categories = Category.includes(:advices).order(:id)

    @categories_json = @categories.as_json(
      only: [ :id, :name ],
      include: {
        advices: { only: [ :id, :title, :body ] }
      }
    )

    # ログイン中ユーザーがお気に入りしてる Advice のID一覧
    @favorite_ids =
      if user_signed_in?
        current_user.favorites.pluck(:advice_id)
      else
        []
      end
  end

  def show
    @owl = Owl.find(params[:id])
  end
end
