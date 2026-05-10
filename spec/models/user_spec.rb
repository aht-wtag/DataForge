require "rails_helper"

RSpec.describe User, type: :model do
  describe "password confirmation" do
    it "is valid when password and confirmation match" do
      user = User.new(
        email: "test@example.com",
        first_name: "Test",
        last_name: "User",
        role: :developer,
        password: "Password123",
        password_confirmation: "Password123"
      )
      expect(user).to be_valid
    end

    it "is invalid when password and confirmation do not match" do
      user = User.new(
        email: "test@example.com",
        first_name: "Test",
        last_name: "User",
        role: :developer,
        password: "Password123",
        password_confirmation: "Different123"
      )
      expect(user).not_to be_valid
      expect(user.errors[:password_confirmation]).to include("doesn't match Password")
    end
  end

  describe "password complexity" do
    it "requires at least one uppercase letter" do
      user = build_user(password: "password123", password_confirmation: "password123")
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("must contain at least one uppercase letter")
    end

    it "requires at least one lowercase letter" do
      user = build_user(password: "PASSWORD123", password_confirmation: "PASSWORD123")
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("must contain at least one lowercase letter")
    end

    it "requires at least one digit" do
      user = build_user(password: "PasswordPassword", password_confirmation: "PasswordPassword")
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("must contain at least one digit")
    end

    it "is valid when all complexity requirements are met" do
      user = build_user(password: "Password123", password_confirmation: "Password123")
      user.valid?
      expect(user.errors[:password]).to be_empty
    end

    it "does not validate complexity when password is blank" do
      user = User.new(
        email: "test@example.com",
        first_name: "Test",
        last_name: "User",
        role: :developer,
        password: nil,
        password_confirmation: nil
      )
      user.valid?
      expect(user.errors[:password]).not_to include("must contain at least one uppercase letter")
    end
  end

  def build_user(password:, password_confirmation:)
    User.new(
      email: "test@example.com",
      first_name: "Test",
      last_name: "User",
      role: :developer,
      password: password,
      password_confirmation: password_confirmation
    )
  end
end
