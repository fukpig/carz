class ControllersController < ApplicationController
  before_action :set_controller, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @controllers = Controller.all
    respond_with(@controllers)
  end

  def show
    respond_with(@controller)
  end

  def new
    @controller = Controller.new
    respond_with(@controller)
  end

  def edit
  end

  def create
    @controller = Controller.new(controller_params)
    @controller.save
    respond_with(@controller)
  end

  def update
    @controller.update(controller_params)
    respond_with(@controller)
  end

  def destroy
    @controller.destroy
    respond_with(@controller)
  end

  private
    def set_controller
      @controller = Controller.find(params[:id])
    end

    def controller_params
      params.require(:controller).permit(:cd, :/home/cars/app/views/messages)
    end
end
