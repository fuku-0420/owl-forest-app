require 'rails_helper'

RSpec.describe "Advices", type: :request do
  describe "GET /advices/:id" do
    let(:user) { create(:user) }
    let(:advice) { create(:advice, views_count: 0) }

    context "未ログインの場合" do
      it "ログインページにリダイレクトされること" do
        get advice_path(advice)

        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログイン済みの場合" do
      before do
        sign_in user
      end

      it "正常に表示できること" do
        get advice_path(advice)

        expect(response).to have_http_status(:ok)
      end

      it "views_count が 1 増えること" do
        expect do
          get advice_path(advice)
          advice.reload
        end.to change(advice, :views_count).from(0).to(1)
      end
    end
  end
end
