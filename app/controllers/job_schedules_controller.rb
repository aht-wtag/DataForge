class JobSchedulesController < ApplicationController
  before_action :set_adapter
  before_action :set_job_schedule, only: [:show, :edit, :update]
  after_action :verify_authorized, except: [:index]

  def index
    @job_schedules = policy_scope(JobSchedule).where(adapter: @adapter).order(created_at: :desc).page(params[:page]).per(25)
    render layout: "adapter"
  end

  def show
    authorize @job_schedule
    render layout: "adapter"
  end

  def new
    @job_schedule = @adapter.job_schedules.build(timezone: "UTC", enabled: true)
    authorize @job_schedule
    render layout: "adapter"
  end

  def create
    @job_schedule = @adapter.job_schedules.build(job_schedule_params)
    authorize @job_schedule

    if @job_schedule.save
      redirect_to [@adapter, @job_schedule], notice: "Job schedule was successfully created."
    else
      render :new, status: :unprocessable_entity, layout: "adapter"
    end
  end

  def edit
    authorize @job_schedule
    render layout: "adapter"
  end

  def update
    authorize @job_schedule

    if @job_schedule.update(job_schedule_params)
      redirect_to [@adapter, @job_schedule], notice: "Job schedule was successfully updated."
    else
      render :edit, status: :unprocessable_entity, layout: "adapter"
    end
  end

  private

  def set_adapter
    @adapter = Adapter.find(params[:adapter_id])
  end

  def set_job_schedule
    @job_schedule = @adapter.job_schedules.find(params[:id])
  end

  def job_schedule_params
    params.require(:job_schedule).permit(:endpoint_id, :cron_expression, :timezone, :enabled)
  end
end
