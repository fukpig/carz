class Admin::CarModelsController < ApplicationController
  before_action :set_models, only: [:edit, :update, :destroy]
  before_action :set_make, only: [:edit, :update, :destroy, :create, :new, :index]
  before_filter :authenticate_user!
  respond_to :html

  def index
    @models = CarsModels.where('make_id = ?', @make_id)
    respond_with(@models)
  end

  def new
    @model = CarsModels.new
    @series = CarsSeries.where('make_id = ?', @make_id)
    respond_with(@model)
  end

  def edit
  end

  def create
    @model = CarsModels.new(model_params)
    @model.make_id = @make_id
    @model.save!
    redirect_to admin_cars_make_car_models_path(@make_id)
  end

  def update
    @model.update(model_params)
    redirect_to admin_cars_make_car_models_path(@make_id)
  end

  def destroy
    @model.destroy
    redirect_to admin_cars_make_car_models_path(@make_id)
  end
	private
    def set_make
      @make_id = params[:cars_make_id]
    end

    def set_models
      @model = CarsModels.find(params[:id])
    end
	
    def model_params
      params.require(:cars_models).permit(:name, :series_id)
    end
end
