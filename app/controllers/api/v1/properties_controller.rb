class Api::V1::PropertiesController < ApplicationController
  # before_action :authorize_request
  before_action :find_property, except: %i[create index]

  ALLOWED_DATA = %i[name description guest_capacity bedrooms beds bathrooms kind size user_id address_id].freeze

  def index
    @properties = Property.all
    render json: { success: true, data: @properties }, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { success: false, error: 'Properties not found' }, status: :not_found
  end

  def show
    render json: { success: true, data: @property }, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { success: false, error: 'Property not found' }, status: :not_found
  end

  def create
    property = Property.new(create_params)

    if property.save
      render json: { success: true, data: property }, status: 201
    else
      render json: { success: false, error: 'Cannot save property' }, status: :bad_request
    end
  end

  def update
    if @property.update
      render json: { success: true, data: @property }, status: :bad_request
    else
      render json: { success: false, errors: 'Cannot update property' }, status: :unprocessable_entity
    end
  end

  def destroy
    @property.destroy
    render json: { success: true, data: @property }, status: :ok
  end

  private

  def find_property
    @property = Property.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { success: false, error: 'Property not found' }, status: :not_found
  end

  def create_params
    params.permit(ALLOWED_DATA)
  end
end
