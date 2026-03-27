require 'rails_helper'

RSpec.describe "Favorites", type: :request do
  describe "POST /favorites" do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    let(:advice) { create(:advice) }

    context "未ログインの場合" do
      it "ログインページにリダイレクトされること" do
        post favorites_path, params: { favorite: { advice_id: advice.id } }

        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログイン済みの場合" do
      before do
        sign_in user
      end

      it "お気に入りが追加されること" do
        expect do
          post favorites_path, params: { favorite: { advice_id: advice.id } }
        end.to change(Favorite, :count).by(1)

        expect(response.parsed_body["status"]).to eq("added")
      end

      it "既にお気に入りがある場合は削除されること（トグル）" do
        create(:favorite, user: user, advice: advice)

        expect do
          post favorites_path, params: { favorite: { advice_id: advice.id } }
        end.to change(Favorite, :count).by(-1)

        expect(response.parsed_body["status"]).to eq("removed")
      end
    end
  end

  describe "GET /favorites" do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }

    context "未ログインの場合" do
      it "ログインページにリダイレクトされること" do
        get favorites_path

        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログイン済みの場合" do
      before do
        sign_in user
      end

      it "正常に表示できること" do
        get favorites_path

        expect(response).to have_http_status(:ok)
      end

      it "自分のお気に入りだけ表示されること" do
        my_advice = create(:advice, title: "自分のお気に入り")
        other_advice = create(:advice, title: "他人のお気に入り")

        create(:favorite, user: user, advice: my_advice)
        create(:favorite, user: other_user, advice: other_advice)

        get favorites_path

        expect(response.body).to include("自分のお気に入り")
        expect(response.body).not_to include("他人のお気に入り")
      end
    end
  end

  describe "DELETE /favorites/:id" do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    let(:advice) { create(:advice) }
    let!(:favorite) { create(:favorite, user: user, advice: advice) }

    context "未ログインの場合" do
      it "ログインページにリダイレクトされること" do
        delete favorite_path(favorite)

        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログイン済みの場合" do
      before do
        sign_in user
      end

      it "お気に入りが削除されること" do
        expect do
          delete favorite_path(favorite)
        end.to change(Favorite, :count).by(-1)

        expect(response).to have_http_status(:ok)
      end

      it "他人のお気に入りは削除できないこと" do
        other_favorite = create(:favorite, user: other_user, advice: create(:advice))

        expect do
          delete favorite_path(other_favorite)
        end.not_to change(Favorite, :count)

        expect(response).to have_http_status(:not_found)
      end

      it "存在しないお気に入りは削除できないこと" do
        delete favorite_path(999999)

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
