class RankingsController < ApplicationController
  before_action :authenticate_user!

  def index
    @ranked_advices = Advice.popular_by_views.limit(10)
  end
end
