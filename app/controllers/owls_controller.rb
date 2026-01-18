class OwlsController < ApplicationController
  def index
    @owls = Owl.all
    @categories = Category.includes(:advices).order(:id)

    @categories_json = @categories.as_json(
      only: [:id, :name],
      include: {
        advices: {
          only: [:id, :title, :body]
        }
      }
    )
  end

  def show
    @owl = Owl.find(params[:id])
  end
end
