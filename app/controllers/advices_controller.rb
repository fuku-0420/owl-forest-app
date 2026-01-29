class AdvicesController < ApplicationController
  before_action :authenticate_user!

  def show
    @advice = Advice.includes(:category).find(params[:id])
  end
end
