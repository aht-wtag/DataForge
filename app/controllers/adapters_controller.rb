class AdaptersController < ApplicationController
  before_action :set_adapter, only: [:show, :edit, :update, :archive]
  after_action :verify_authorized, except: [:index]

  def index
    @adapters = policy_scope(Adapter).order(created_at: :desc).page(params[:page]).per(25)
  end

  def show
    authorize @adapter
    @endpoints_count = @adapter.endpoints.count
    @credentials_count = @adapter.credentials.count
    @schedules_count = @adapter.job_schedules.count
    @recent_logs = @adapter.execution_logs.recent.limit(5)
    render layout: "adapter"
  end

  def new
    @adapter = current_user.adapters.build
    authorize @adapter
  end

  def create
    @adapter = current_user.adapters.build(adapter_params)
    authorize @adapter

    if @adapter.save
      redirect_to @adapter, notice: "Adapter was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @adapter
    render layout: "adapter"
  end

  def update
    authorize @adapter

    if @adapter.update(adapter_params)
      redirect_to @adapter, notice: "Adapter was successfully updated."
    else
      render :edit, status: :unprocessable_entity, layout: "adapter"
    end
  end

  def archive
    authorize @adapter

    if @adapter.archive!
      redirect_to adapters_path, notice: "Adapter was successfully archived."
    else
      redirect_to @adapter, alert: "Unable to archive adapter."
    end
  end

  private

  def set_adapter
    @adapter = Adapter.find(params[:id])
  end

  def adapter_params
    params.require(:adapter).permit(
      :name, :base_url, :description, :rate_limit, :timeout, :status, :adapter_type,
      config: %i[DiLocBaseurl apiKey oevpadCockpiturl CockpitApiKey startDateTime endDateTime offsetHours oevpadCockpiturlSslRejectUnauthorized]
    )
  end
end
