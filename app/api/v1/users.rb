module V1
  class Users < Grape::API

    resource :users do
      desc 'GET /api/v1/users/me'
      get '/me' do
				authorize
			  {"result" => "success", "data" => {"name" => current_user.name, "email" => current_user.email, "avatar" => current_user.avatar.url}}
      end
	  
	  desc 'POST /api/v1/users/authorize'
      params do
	    requires :email, type:String
    	requires :password, type:String
      end
	  post '/authorize' do
		token = authenticated_user(params[:email], params[:password])
		{:status => 'success', :access_token => token }
      end
	  
      desc 'POST /api/v1/users/me/avatar/upload'
      params do
	    requires :image, type:String
    	requires :access_token, type:String
      end
	  post '/me/avatar/upload' do
		authorize
		image = params['image'].gsub("\\\\", "").tr(" ","+")
		avatar = current_user.decode_image_data(image)
		if !avatar.nil? 
		  {"result" => "success", "data" => {"message" => current_user.avatar.url}}
		else
		  {"result" => "errors", "data" => {"message" => "Upload error. Try later"}}
		end
      end

	  
	  desc 'GET /api/v1/users/auth/:provider'
	  get 'auth/:provider' do
		redirect '/users/auth/' + params[:provider]
	  end
	  
	  desc 'POST /api/v1/users/create'
	  params do
		  requires :email, type:String
		  requires :phone, type:String
		  requires :name, type:String
		  requires :company_name, type:String
		  requires :company_phone, type:String
		  requires :dealer_number, type:String
		  requires :dealer_solution_number, type:String
		  requires :company_phone, type:String
		  requires :password, type:String
		  requires :password_confirmation, type:String
		  optional :image, type:String
	  end
	  post '/register' do
			user = User.create!({
				name:params[:name],
				email:params[:email],
				phone:params[:phone],
				dealer_number:params[:dealer_number],
				dealer_solution_number:params[:dealer_solution_number],
				company_name:params[:company_name],
				company_phone:params[:company_phone],
				password:params[:password],
				password_confirmation:params[:password_confirmation]
			  })
			if !params[:image].nil?
			  image = params['image'].gsub("\\\\", "").tr(" ","+")
			  avatar = user.decode_image_data(image)
			end
			{ :status => 'success', :access_token => user.authentication_token } 
	  end
    end
  end
end
