class OwlsController < ApplicationController
  CATEGORY_ORDER = {
    "入門" => 0,
    "Rails" => 1,
    "SQL" => 2,
    "設計" => 3,
    "開発" => 4,
    "エラー" => 5,
    "学習" => 6,
    "モチベ" => 7,
    "みんなのお悩み解決" => 8
  }.freeze

  def index
    @owls = Owl.all
    @categories = Category.includes(:advices)
                          .to_a
                          .sort_by { |category| CATEGORY_ORDER.fetch(category.name, 999) }

    @categories_json = @categories.as_json(
      only: [ :id, :name ],
      include: {
        advices: { only: [ :id, :title, :body ] }
      }
    )

    @popular_advices = Advice.includes(:category).popular_by_views.limit(10)

    @popular_advices_json = @popular_advices.as_json(
      only: [ :id, :title, :views_count ],
      include: {
        category: { only: [ :id, :name ] }
      }
    )

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
