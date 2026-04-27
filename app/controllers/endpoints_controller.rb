class EndpointsController < ApplicationController
  before_action :set_adapter
  before_action :set_endpoint, only: [:show, :edit, :update]
  after_action :verify_authorized, except: [:index]

  def index
    @endpoints = policy_scope(Endpoint).where(adapter: @adapter).order(created_at: :desc).page(params[:page]).per(25)
    render layout: "adapter"
  end

  def show
    authorize @endpoint
    @transformation_rules = @endpoint.transformation_rules.order(:position)
    render layout: "adapter"
  end

  def new
    @endpoint = @adapter.endpoints.build
    authorize @endpoint
    render layout: "adapter"
  end

  def create
    @endpoint = @adapter.endpoints.build(endpoint_params)
    authorize @endpoint

    if @endpoint.save
      redirect_to [@adapter, @endpoint], notice: "Endpoint was successfully created."
    else
      render :new, status: :unprocessable_entity, layout: "adapter"
    end
  end

  def edit
    authorize @endpoint
    render layout: "adapter"
  end

  def update
    authorize @endpoint

    if @endpoint.update(endpoint_params)
      redirect_to [@adapter, @endpoint], notice: "Endpoint was successfully updated."
    else
      render :edit, status: :unprocessable_entity, layout: "adapter"
    end
  end

  private

  def set_adapter
    @adapter = Adapter.find(params[:adapter_id])
  end

  def set_endpoint
    @endpoint = @adapter.endpoints.find(params[:id])
  end

  def endpoint_params
    params.require(:endpoint).permit(:http_method, :path, :name, :description, :enabled, headers: {}, payload_template: {})
  end
end
