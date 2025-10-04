class OwlsController < ApplicationController
  def index
    @owls = Owl.all
  end

  def show
    @owl = Owl.find(params[:id])
  end
end
