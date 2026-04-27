class CredentialsController < ApplicationController
  before_action :set_adapter
  before_action :set_credential, only: [:show, :edit, :update, :destroy]
  after_action :verify_authorized, except: [:index]

  def index
    @credentials = policy_scope(Credential).where(adapter: @adapter).order(created_at: :desc).page(params[:page]).per(25)
    render layout: "adapter"
  end

  def show
    authorize @credential
    render layout: "adapter"
  end

  def new
    @credential = @adapter.credentials.build
    authorize @credential
    render layout: "adapter"
  end

  def create
    @credential = @adapter.credentials.build(credential_params)
    authorize @credential

    if @credential.save
      redirect_to [@adapter, @credential], notice: "Credential was successfully created."
    else
      render :new, status: :unprocessable_entity, layout: "adapter"
    end
  end

  def edit
    authorize @credential
    render layout: "adapter"
  end

  def update
    authorize @credential

    if @credential.update(credential_params)
      redirect_to [@adapter, @credential], notice: "Credential was successfully updated."
    else
      render :edit, status: :unprocessable_entity, layout: "adapter"
    end
  end

  def destroy
    authorize @credential
    @credential.destroy!
    redirect_to adapter_credentials_path(@adapter), notice: "Credential was successfully deleted."
  end

  private

  def set_adapter
    @adapter = Adapter.find(params[:adapter_id])
  end

  def set_credential
    @credential = @adapter.credentials.find(params[:id])
  end

  def credential_params
    p = params.require(:credential).permit(:name, :credential_type, :auth_header_name, :value)
    p.delete(:value) if p[:value].blank? && action_name == "update"
    p
  end
end
