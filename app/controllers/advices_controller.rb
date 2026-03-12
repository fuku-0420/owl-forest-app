class AdvicesController < ApplicationController
  before_action :authenticate_user!

  def show
    @advice = Advice.includes(:category).find(params[:id])
    @advice.increment!(:views_count)
  end
end
