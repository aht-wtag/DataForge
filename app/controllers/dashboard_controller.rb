class DashboardController < ApplicationController
  def index
    authorize :dashboard, :index?
    @adapters = policy_scope(Adapter)
    @recent_logs = policy_scope(ExecutionLog).recent.limit(10)

    if current_user.admin?
      @users_count = User.count
      @adapters_count = Adapter.active.count
      @logs_count = ExecutionLog.count
      @stored_data_count = StoredDatum.count
      @failed_logs = ExecutionLog.failed.recent.limit(5)
    elsif current_user.developer?
      @my_adapters_count = @adapters.active.count
      @my_logs_count = policy_scope(ExecutionLog).count
    end
  end
end
