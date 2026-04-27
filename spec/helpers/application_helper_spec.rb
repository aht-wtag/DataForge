require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#status_badge" do
    it "returns a span with the humanized status text" do
      badge = helper.status_badge(:active)
      expect(badge).to include("Active")
    end

    it "applies green styling for :active status" do
      badge = helper.status_badge(:active)
      expect(badge).to include("bg-green-100")
    end

    it "applies blue styling for :running status" do
      badge = helper.status_badge(:running)
      expect(badge).to include("bg-blue-100")
    end

    it "applies red styling for :failed status" do
      badge = helper.status_badge(:failed)
      expect(badge).to include("bg-red-100")
    end

    it "applies yellow styling for :pending status" do
      badge = helper.status_badge(:pending)
      expect(badge).to include("bg-yellow-100")
    end

    it "applies gray styling for unknown statuses" do
      badge = helper.status_badge(:unknown_status)
      expect(badge).to include("bg-gray-100")
    end

    it "handles string statuses" do
      badge = helper.status_badge("completed")
      expect(badge).to include("Completed")
    end
  end

  describe "#role_badge" do
    it "returns uppercase role text" do
      user = User.new(role: :admin, email: "a@b.com", first_name: "A", last_name: "B")
      badge = helper.role_badge(user)
      expect(badge).to include("ADMIN")
    end

    it "applies red styling for admin" do
      user = User.new(role: :admin, email: "a@b.com", first_name: "A", last_name: "B")
      badge = helper.role_badge(user)
      expect(badge).to include("bg-red-100")
    end

    it "applies blue styling for developer" do
      user = User.new(role: :developer, email: "a@b.com", first_name: "A", last_name: "B")
      badge = helper.role_badge(user)
      expect(badge).to include("bg-blue-100")
    end

    it "applies green styling for viewer" do
      user = User.new(role: :viewer, email: "a@b.com", first_name: "A", last_name: "B")
      badge = helper.role_badge(user)
      expect(badge).to include("bg-green-100")
    end
  end
end
