class TransformationRulesController < ApplicationController
  before_action :set_adapter
  before_action :set_endpoint
  before_action :set_transformation_rule, only: [:show, :edit, :update]
  after_action :verify_authorized, except: [:index]

  def index
    @transformation_rules = policy_scope(TransformationRule).where(endpoint: @endpoint).order(:position).page(params[:page]).per(25)
    render layout: "adapter"
  end

  def show
    authorize @transformation_rule
    render layout: "adapter"
  end

  def new
    @transformation_rule = @endpoint.transformation_rules.build
    authorize @transformation_rule
    render layout: "adapter"
  end

  def create
    @transformation_rule = @endpoint.transformation_rules.build(transformation_rule_params)
    authorize @transformation_rule

    if @transformation_rule.save
      redirect_to [@adapter, @endpoint, @transformation_rule], notice: "Transformation rule was successfully created."
    else
      render :new, status: :unprocessable_entity, layout: "adapter"
    end
  end

  def edit
    authorize @transformation_rule
    render layout: "adapter"
  end

  def update
    authorize @transformation_rule

    if @transformation_rule.update(transformation_rule_params)
      redirect_to [@adapter, @endpoint, @transformation_rule], notice: "Transformation rule was successfully updated."
    else
      render :edit, status: :unprocessable_entity, layout: "adapter"
    end
  end

  private

  def set_adapter
    @adapter = Adapter.find(params[:adapter_id])
  end

  def set_endpoint
    @endpoint = @adapter.endpoints.find(params[:endpoint_id])
  end

  def set_transformation_rule
    @transformation_rule = @endpoint.transformation_rules.find(params[:id])
  end

  def transformation_rule_params
    params.require(:transformation_rule).permit(:source_path, :target_field, :target_type, :default_value, :transformation_expression, :position, :enabled)
  end
end
