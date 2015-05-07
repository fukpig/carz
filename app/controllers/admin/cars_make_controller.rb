class Admin::CarsMakeController < ApplicationController
  before_action :set_make, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_user!
  respond_to :html

  def index
    @makes = CarsMake.all
    respond_with(@makes)
  end

  def new
    @make = CarsMake.new
    respond_with(@make)
  end

  def edit
  end

  def create
    @make = CarsMake.new(make_params)
    @make.save!
    redirect_to admin_cars_make_index_path
  end

  def update
    @make.update(make_params)
    redirect_to admin_cars_make_index_path
  end

  def destroy
    @make.destroy
    redirect_to admin_cars_make_index_path
  end
	private
    def set_make
      @make = CarsMake.find(params[:id])
    end
	
    def make_params
      params.require(:cars_make).permit(:name)
    end
end
