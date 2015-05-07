class CarsController < ApplicationController
  require 'csv'
  before_action :set_car, only: [:show, :edit, :update, :destroy, :edit_status, :update_status, :follow, :unfollow]
  before_filter :authenticate_user!
  before_filter :check_user_fields,:check_subscription_status
  respond_to :html

  def index
    @cars = Car.all
    respond_with(@cars)
  end

  def show
    respond_with(@car)
  end

  def new
    @car = Car.new
    respond_with(@car)
  end

  def edit
  end

  def vin
    info = Identicar.vin(params["vin"])
    render json: info
  end

  def create
    @car = Car.new(car_params)
	  @car.sync = false
    @car.save
    respond_with(@car)
  end

  def update
    @car.update(car_params)
    respond_with(@car)
  end
  
  def edit_status
  end
  
  def set_status
	@car.update(status_params)
	respond_with(@car)
  end

  def destroy
    @car.destroy
    respond_with(@car)
  end
  
  def follow
    followed_car = FollowedCar.where('car_id = ? and user_id = ?', @car.id, current_user.id).first
    if followed_car.nil?
      followed_car = FollowedCar.new(:car_id => @car.id, :user_id => current_user.id)
      if followed_car.save
        @status = 'success'
      else
        @status = 'errors'
      end
    end
    render layout:false
  end

  def unfollow 
    followed_car = FollowedCar.where('car_id = ? and user_id = ?', @car.id, current_user.id).first
    if followed_car.destroy
      @status = 'success'
    else
      @status = 'errors'
    end
    render layout:false
  end

  def followed_cars
    @cars = current_user.followed_cars
  end

  def changeset
    if current_user.followed_cars.where('car_id = ?', params['id']).first
      @car = current_user.followed_cars.find(params['id'])
    else 
      redirect_to followed_cars_path
    end
  end


  def parse_csv
	  CSV.foreach('/home/cars/public/uploads/dealers_network/file/13156.csv', :headers => true) do |row|
  	  car_hash = {}
	    row.each do |k, v|
		    key = k.titleize
		    key = key.downcase.tr(' ', '_')
		    car_hash[key] = v
	    end
	    car_hash['sync'] = true
	    car = Car.create!(car_hash)
	    set_images(car)
	  end
  end

  private
  def set_car
    @car = Car.find(params[:id])
  end
	
	
	def set_images(car)
		images = Dir.glob("/home/cars/public/uploads/dealers_network/images/*_0000#{car.stock_no}_*.jpg")
		images.each do |image|
			#image_path = image.sub!("/home/cars/public","")
			if Image.where(image_file_name: image).empty?
			  i = Image.new
			  File.open(image) do |f|
				  i.image_file_name = f
			  end
			  i.car_id = car.id
			  i.save!
			end
		end
	end
	
	def titleize(str)
		str.split(/ |\_/).map().join(" ")
    end

    def car_params
      params.require(:car).permit(:client, :make, :stock, :model, :manufacture_year, :series, :badge, :door, :body, :seat, :status, :rating, :image)
    end
	
	def status_params
		params.require(:car).permit(:status)
	end
end
