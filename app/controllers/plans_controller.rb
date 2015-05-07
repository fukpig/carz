class PlansController < ApplicationController
  before_action :set_plan, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_user!
  before_filter :check_user_fields,:check_subscription_status
  respond_to :html

  def index
	authorize! :read, @plans
    @plans = Plan.all
    respond_with(@plans)
  end

  def show
    respond_with(@plan)
  end

  def new
    @plan = Plan.new
    respond_with(@plan)
  end

  def edit
  end

  def create
    @plan = Plan.new(plan_params)
	  @plan.save
    redirect_to plans_path
  end

  def update
    @plan.update(plan_params)
    redirect_to plans_path
  end
  
  def destroy
    @plan.destroy
    respond_with(@plan)
  end
  
  private
    def set_plan
      @plan = Plan.find(params[:id])
    end

    def plan_params
      params.require(:plan).permit(:name, :description, :month_price, :year_price)
    end
end
