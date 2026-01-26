class Users::WithdrawalsController < ApplicationController
  before_action :authenticate_user!

  def show
  end

  def destroy
    user = current_user
    sign_out(user)
    user.destroy
    redirect_to root_path, notice: "退会しました。ご利用ありがとうございました。"
  end
end
