class EmailCheckController < ApplicationController
  skip_before_action :authenticate_user!
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  def show
    render json: { taken: User.where(email: params[:email]).exists? }
  end
end
