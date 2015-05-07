require 'grape-swagger'

module MyErrorFormatter
  def self.call message, backtrace, options, env
      { :status => 'error', :response => message }.to_json
  end
end


module V1
  class Base < Grape::API
    format :json
    content_type :xml, "text/xml"
    content_type :json, "application/json"
    default_format :json

    # for Grape::Jbuilder
    formatter :json, Grape::Formatter::Jbuilder
	error_formatter :json, MyErrorFormatter

    prefix :api
    version 'v1', using: :path 

    helpers do
      def warden
        env['warden']
      end

	  def authorize
	    error!("401 Unauthorized", 401) unless authenticated
	  end
	  
	  def authenticated_user(email, password)
		user = User.find_for_authentication(:email => email)
		if user && user.valid_password?(password) 
		  user.authentication_token 
		else 
		  error!("401 Unauthorized", 401)
		end
	  end


    def get_conversations(car, current_user)
      conversations = car.conversations.where('sender_id = ? or recipient_id = ?', current_user.id, current_user.id).select(:id)
      return conversations
    end
	  
	  
      def authenticated
        #return true if warden.authenticated?
        params[:access_token] && @user = User.find_by_authentication_token(params[:access_token])
      end

      def current_user
        warden.user || @user
      end
    end
	
	
    rescue_from ActiveRecord::RecordNotFound do |e|
      error_response(message:  e.message, status: 404)
    end

    rescue_from Grape::Exceptions::ValidationErrors do |e|
      error_response(message:e.message, status:500)
    end

    rescue_from :all do |e|
      #error_response(message: "Internal server error", status: 500)
	  error_response(message: e.message, status: 500)
    end
	
	mount V1::Cars
	mount V1::Users
  mount V1::Conversations

    add_swagger_documentation api_version: 'v1'
  end
end
