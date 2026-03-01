# app/controllers/admin/advices_controller.rb
class Admin::AdvicesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!
  before_action :set_advice, only: %i[show edit update destroy]

  def index
    @advices = Advice.includes(:category).order(created_at: :desc)
  end

  def show; end
  def edit; end

  def update
    if @advice.update(advice_params)
      redirect_to admin_advice_path(@advice), notice: "更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @advice.destroy!
    redirect_to admin_advices_path, notice: "削除しました"
  end

  private

  def set_advice
    @advice = Advice.find(params[:id])
  end

  def advice_params
    params.require(:advice).permit(:title, :body, :category_id)
  end

  def require_admin!
    return if current_user&.admin?
    redirect_to root_path, alert: "権限がありません"
  end
end
