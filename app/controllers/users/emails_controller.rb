class Users::EmailsController < ApplicationController
  before_action :authenticate_user!

  def edit
    @user = current_user
  end

  def update
    @user = current_user

    if @user.update_with_password(email_params)
      bypass_sign_in(@user)
      redirect_to edit_users_email_path, notice: "メールアドレスを更新しました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def email_params
    params.require(:user).permit(:email, :current_password)
  end
end
