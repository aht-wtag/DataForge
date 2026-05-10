require "rails_helper"

RSpec.describe EmailCheckController, type: :controller do
  let(:user) { User.create!(email: "auth@example.com", password: "Password123", password_confirmation: "Password123", first_name: "Auth", last_name: "User", role: :developer, confirmed_at: Time.current) }

  before { sign_in user }

  describe "GET #show" do
    let!(:existing_user) { User.create!(email: "taken@example.com", password: "Password123", password_confirmation: "Password123", first_name: "Taken", last_name: "User", role: :developer, confirmed_at: Time.current) }

    it "returns taken: true when email is already registered" do
      get :show, params: { email: "taken@example.com" }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq("taken" => true)
    end

    it "returns taken: false when email is not registered" do
      get :show, params: { email: "new@example.com" }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq("taken" => false)
    end

    it "returns taken: false when email param is empty" do
      get :show, params: { email: "" }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq("taken" => false)
    end
  end
end
