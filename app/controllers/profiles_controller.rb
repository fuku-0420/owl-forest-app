class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def show
    @profile = current_user.profile || current_user.build_profile
  end

  def edit
    @profile = current_user.profile || current_user.build_profile
  end

  def update
    @profile = current_user.profile || current_user.build_profile

    if @profile.update(profile_params)
      redirect_to profile_path, notice: "プロフィールを更新しました"
      # 設定ハブに戻す場合↓
      # redirect_to settings_path, notice: "プロフィールを更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:profile).permit(:display_name, :bio, :avatar)
  end
end
