class Admin::CarSeriesController < ApplicationController
  before_action :set_series, only: [:edit, :update, :destroy]
  before_action :set_make, only: [:edit, :update, :destroy, :create]
  before_filter :authenticate_user!
  respond_to :html

  def index
    @series = CarsSeries.all
    respond_with(@series)
  end

  def new
    @series = CarsSeries.new
    respond_with(@series)
  end

  def edit
  end

  def create
    @series = CarsSeries.new(series_params)
    @series.make_id = @make_id
    @series.save!
    redirect_to admin_cars_make_car_series_index_path(@make_id)
  end

  def update
    @series.update(series_params)
    redirect_to admin_cars_make_car_series_index_path(@make_id)
  end

  def destroy
    @series.destroy
    redirect_to admin_cars_make_car_series_index_path(@make_id)
  end
	private
    def set_make
      @make_id = params[:cars_make_id]
    end

    def set_series
      @series = CarsSeries.find(params[:id])
    end
	
    def series_params
      params.require(:cars_series).permit(:name)
    end
end
