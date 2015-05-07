module V1
  class Cars < Grape::API

    resource :cars do
      desc 'GET /api/v1/cars'
      params do
        requires :access_token, type:String
      end
      get '/', jbuilder: 'v1/cars/index' do
	    authorize
        @cars = Car.all.order('id ASC')
      end
	  
	  desc 'GET /api/v1/cars/search'
	  params do
	    requires :search, type:String
	    requires :access_token, type:String
	  end
	  get '/search', jbuilder: 'v1/cars/index' do
	    authorize
		@cars = Car.search(@params[:search])
	  end
	  
	  desc 'GET /api/v1/cars/search_by_fields'
	  params do
	  	requires :access_token, type:String
		group :search, type: Hash do
		end
	  end
	  get '/search_by_fields', jbuilder: 'v1/cars/index' do
		authorize
		@cars = Car.search "", :conditions => search_params(params), :per_page => 500
	  end
	  
	  desc 'GET /api/v1/cars/search_by_fields'
	  params do
	  	requires :access_token, type:String
		group :search, type: Hash do
		end
	  end
	  get '/search_test', jbuilder: 'v1/cars/index' do
		authorize
		with_params = with_params(params)
		#{"test"=>with_params}
		@cars = Car.search "", :conditions => search_params(params), :with => with_params, :per_page => 500
	  end
	  
	  desc 'get /api/v1/cars/makes'	  
	  params do
	  	requires :access_token, type:String
        requires :access_token, type:String
      end
	  get '/makes' do
	    authorize
		info = CarsMake.all.select("id, name")
		{"status"=>"success","message" => info.sort, "count" => info.to_a.count}
	  end

	  desc 'get /api/v1/cars/models'	
	  params do
	  	requires :access_token, type:String
	    requires :make, type:String
	  end  
	  get '/models' do
	    authorize
		make = CarsMake.find_by_name(params['make'])
		models = CarsModels.where('make_id = ?', make.id).select('id, name')
		{"status"=>"success","message" => models, "count" => models.to_a.count}
	  end


	  desc 'get /api/v1/cars/test'	
	  get '/test' do
	  	search_params = Car.search_params(params)
	  	{"params" => search_params}
	  end

	  desc 'get /api/v1/cars/filters'
	  params do
        requires :access_token, type:String
      end	
	  get '/filters' do
	    authorize
		options = SearchOption.all
		info = Array.new
		options.each do |option|
			values = Array.new
			if option.field_type == 'list'
				values = option.values.split(",")
			end
			info << { "id" => option.id, "field_type" => option.field_type, "values" => values }
		end
		{"status"=>"success","message" => info}
	  end
		
	   desc 'get /api/v1/cars/unique'
	   params do
        requires :access_token, type:String
       end
       get '/unique' do
          authorize
          info = Car.connection.select_values("select distinct(make) from cars")
          info.delete(nil)
          {"status"=>"success","message" => info.sort, "count" => info.count}
       end



	  desc 'get /api/v1/cars/unique1'
	  params do
        requires :access_token, type:String
      end	  
	  get '/unique1' do
	    authorize
		
		#cars = Car.search "", :conditions => search_params(params), :per_page => 500
		search_params = Car.search_params(params)
		cars = Car.search search_params, :per_page => 500
		info = Car.get_unique(cars)
		{"status"=>"success","message" => info, "count" => info.count}
	  end
	  
	  
	  desc 'POST /api/v1/cars/create'
	  params do
		requires :client_no, type:Integer
		requires :stock_no, type:Integer
		requires :manu_year, type:String
		requires :make, type:String
		requires :model, type:String
		requires :series, type:String
		requires :badge, type:String
		requires :body, type:String
		requires :doors, type:String
		requires :seats, type:String
		requires :body_colour, type:String
		requires :trim_colour, type:String
		requires :gears, type:String
		requires :gearbox, type:String
		requires :fuel_type, type:String
		requires :retail, type:String
		requires :rego, type:String
		requires :odometer, type:String
		requires :cylinders, type:String
		requires :engine_capacity, type:String
		requires :engine_number, type:String
		requires :vin_number, type:String
		requires :manu_month, type:String
		requires :options, type:String
		requires :comments, type:String
		requires :nvic, type:String
		requires :redbookcode, type:String
		requires :location, type:String
	  end
	  
	  post '/create' do
	    authorize
		blacklist_columns = ["id", "status", "created_at", "updated_at"]
	    car_columns = Car.columns
		params_columns = Array.new()
		car_columns.map do |c|
			params_columns << c.name if !blacklist_columns.include?(c.name)
		end
		
		params_hash = {}
		params_columns.map do |c|
			params_hash[c] = @params[c]
		end

		params_hash[:dealer_code] = current_user.dealer_number
		
		
		Car.create!(params_hash)
		
		{'status' => 'success'}
	  end


	  params do
        requires :access_token, type:String

      end
	  post '/:car_id/follow/' do
	  	authorize
	  	car = Car.find(params[:car_id])
	  	followed_car = FollowedCar.where('car_id = ? and user_id = ?', car.id, current_user.id).first
	    if followed_car.nil?
	      followed_car = FollowedCar.new(:car_id => car.id, :user_id => current_user.id)
	      if followed_car.save
	        status = 'success'
	      else
	        status = 'errors'
	      end
	    end
	    {'status' => status}
	  end

	  params do
        requires :access_token, type:String
      end
	  post '/:car_id/unfollow/' do
	  	authorize
	  	car = Car.find(params[:car_id])
	  	followed_car = FollowedCar.where('car_id = ? and user_id = ?', car.id, current_user.id).first
	    if followed_car.destroy
	      status = 'success'
	    else
	      status = 'errors'
	    end
	    {'status' => status}
	  end

	  params do
        requires :access_token, type:String
      end
	  get '/followed', jbuilder: 'v1/cars/index' do
	  	authorize
	  	@cars = current_user.followed_cars
	  end
	  
	  desc 'get /api/v1/cars/set_and_forget'
	  params do
		  group :search, type: Hash do
		  end
	  end
	  get '/set_and_forget' do
		authorize
		search = params[:search].to_json
		Setandforget.create!(:search_params => search, :user_id => current_user.id)
		{"status" => "success"}
	  end
	  
	  desc 'get /api/v1/cars/:car_id/info'
	  get '/:car_id/info', jbuilder: 'v1/cars/info' do
	    authorize
		@car = Car.find(@params[:car_id])
	  end
	  
	  params do
		requires :status, type:String
	  end
	  
	  put '/:car_id/status/update' do
	    authorize
		car = Car.find(@params[:car_id])
		if car.update_attribute(:status, @params[:status])
			{'status' => 'success'}
		end
	  end
	  	  
    end
  end
end
