class Api::V1::UsersController < ApplicationController
  before_action :authenticate_user, only: [:index]
  ALLOWED_DATA = %i[name email password].freeze

  def index
    if @current_user.role == 1
      @users = User.all
      render json: { success: true, data: @users }, status: :ok
    else
      render json: { success: false, error: 'You are not authorized to complete this action.' }, status: :forbidden
    end
  end

  def show
    @user = User.find(params[:id])
    @user.password_digest = nil
    render json: { success: true, data: @user }, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { success: false, error: 'No user found with this ID.' }, status: :not_found
  rescue ActiveRecord::ActiveRecordError
    render json: { success: false, error: 'Internal server error.' }, status: :internal_server_error
  end

  def create
    user = User.new(create_user_params)
    if user.save
      render json: { success: true, data: user }, status: :created
    else
      render json: { success: false, error: 'User could not be registered.' }, status: :bad_request
    end
  end

  def update
    user = User.find(params[:id])
    if user.update(update_user_params)
      render json: { success: true, data: user }, status: :ok
    else
      render json: { success: false, errors: 'Cannot update user' }, status: :unprocessable_entity
    end
  end

  def update_user_params
    params.permit(ALLOWED_DATA)
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    render json: { success: true, data: @user }, status: :ok
  end

  private

  def find_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { success: false, error: 'User not found' }, status: :not_found
  end

  def create_user_params
    params.permit(:name, :email, :password, :role)
  end
end
