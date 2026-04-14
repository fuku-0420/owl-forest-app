class OwlsController < ApplicationController
  CATEGORY_ORDER = {
    "入門" => 0,
    "Rails" => 1,
    "SQL" => 2,
    "Git" => 3,
    "設計" => 4,
    "開発" => 5,
    "エラー" => 6,
    "学習" => 7,
    "モチベ" => 8,
    "みんなのお悩み解決" => 9
  }.freeze

  def index
    @owls = Owl.all

    @categories = Category.includes(:advices)
                          .to_a
                          .sort_by { |category| CATEGORY_ORDER.fetch(category.name, 999) }

    @categories_json = @categories.map do |category|
      {
        id: category.id,
        name: category.name,
        advices: category.advices.sort_by { |advice| [ advice.position || 999, advice.id ] }.map do |advice|
          {
            id: advice.id,
            title: advice.title,
            body: advice.body
          }
        end
      }
    end

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
