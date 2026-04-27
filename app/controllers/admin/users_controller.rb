class Admin::UsersController < ApplicationController
  before_action :require_admin!
  before_action :set_user, only: [:show, :update_role]

  def index
    authorize User
    @users = policy_scope(User).order(created_at: :desc).page(params[:page]).per(25)
  end

  def show
    authorize @user
  end

  def update_role
    authorize @user
    if @user.update(role: params[:role])
      redirect_to admin_users_path, notice: "#{@user.full_name}'s role was updated to #{params[:role].humanize}."
    else
      redirect_to admin_users_path, alert: "Failed to update role: #{@user.errors.full_messages.join(', ')}"
    end
  end

  private

  def require_admin!
    unless current_user.admin?
      flash[:alert] = "You are not authorized to access this area."
      redirect_to root_path
    end
  end

  def set_user
    @user = User.find(params[:id])
  end
end
