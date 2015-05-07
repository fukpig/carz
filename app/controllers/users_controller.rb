class UsersController < ApplicationController
  before_action :set_user, only: [:show, :destroy]
  before_filter :authenticate_user!, except: [:test_redirect]

  respond_to :html

  def index
	  @users = User.all
    respond_with(@users)
  end

  def show
    respond_with(@user)
  end

  def new
    @user = User.new
    respond_with(@user)
  end

  def profile
    @user = current_user
  end
  
  def create
    @user = User.new(user_params)
    @user.save
    respond_with(@user)
  end

  def update
    @user = current_user
    @user.update(user_params)
    redirect_to cars_path
  end

  def destroy
    @user.destroy
    respond_with(@user)
  end

  def network
    @network_members = Network.get_all_members(current_user)
  end

  private
    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:name, :company_name, :company_phone, :phone, :dealer_number, :dealer_solution_number)
    end
end
