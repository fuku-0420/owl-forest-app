# app/controllers/admin/advice_suggestions_controller.rb
class Admin::AdviceSuggestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!
  before_action :set_advice_suggestion, only: %i[
    show destroy new_advice create_advice reject restore delete_forever
  ]

  def index
    base = AdviceSuggestion.includes(:user, :category, :advice)

    @pending  = base.status_pending.order(created_at: :asc)
    @approved = base.status_approved.order(created_at: :desc)
    @rejected = base.status_rejected.order(created_at: :desc)
    @deleted  = base.status_deleted.order(updated_at: :desc)
  end

  def show
  end

  # 編集して公開フォーム（承認後の更新もここを使う）
  def new_advice
    @advice = Advice.find_or_initialize_by(advice_suggestion_id: @advice_suggestion.id)
    @advice.category ||= @advice_suggestion.category

    # ✅ 初回（まだ公開Adviceが無い時）だけ下書きを入れる
    if @advice.new_record?
      @advice.title = @advice_suggestion.title.presence || @advice_suggestion.body.to_s.truncate(30)
      @advice.body  = @advice_suggestion.body.to_s
    end
  end

  # 公開（作成 or 更新）
  def create_advice
    advice = Advice.find_or_initialize_by(advice_suggestion_id: @advice_suggestion.id)

    ActiveRecord::Base.transaction do
      advice.assign_attributes(advice_params)

      # 投稿のカテゴリに寄せたいなら =（常に上書き）
      # advice.category_id = @advice_suggestion.category_id
      # 既存を尊重するなら ||=（今のあなたの意図ならこっちでもOK）
      advice.category_id ||= @advice_suggestion.category_id

      advice.save!
      @advice_suggestion.update!(status: :approved)
    end

    redirect_to admin_advice_suggestions_path, notice: "公開しました"
  rescue ActiveRecord::RecordInvalid
    @advice = advice
    flash.now[:alert] = "入力内容を確認してください"
    render :new_advice, status: :unprocessable_entity
  end

  def reject
    @advice_suggestion.update!(status: :rejected)
    redirect_to admin_advice_suggestions_path, notice: "却下しました"
  end

  # ゴミ箱へ（物理削除ではない）
  def destroy
    @advice_suggestion.advice&.destroy!
    @advice_suggestion.update!(status: :deleted)
    redirect_to admin_advice_suggestions_path, notice: "ゴミ箱に移動しました"
  end

  # ゴミ箱から復元（承認待ちへ戻す）
  def restore
    @advice_suggestion.update!(status: :pending)
    redirect_to admin_advice_suggestions_path, notice: "承認待ちに戻しました"
  end

  # 完全削除（戻せない）
  def delete_forever
    @advice_suggestion.destroy!
    redirect_to admin_advice_suggestions_path, notice: "完全に削除しました"
  end

  private

  def set_advice_suggestion
    @advice_suggestion = AdviceSuggestion.includes(:user, :category, :advice).find(params[:id])
  end

  def advice_params
    params.require(:advice).permit(:title, :body)
  end

  def require_admin!
    return if current_user&.admin?

    redirect_to root_path, alert: "権限がありません"
  end
end
