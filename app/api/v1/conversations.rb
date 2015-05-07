module V1
  class Conversations < Grape::API

    resource :conversations do
      desc 'GET /api/v1/cars'
      params do
	      requires :sel, type:Integer
        optional :car, type:Integer
        requires :access_token, type:String
	    end
      get '/' do
  	    authorize
        car = nil
        car = params[:car] if !params[:car].nil? && params[:car] != ''
  	    if User.exists?(params[:sel])
            conversation = Conversation.create_converstion(current_user.id, params[:sel], car)
      	end	
      	info = Conversation.get_messages(conversation.messages, current_user)
      	{"status" => "success", "messages" => info, "conversation" => conversation.id}
      end


      params do
        requires :conversation, type:Integer
        requires :access_token, type:String
      end
      get '/find' do
        authorize
        conversation = current_user.conversations.find(params[:conversation])
        info = Conversation.get_messages(conversation.messages, current_user)
        {"status" => "success", "messages" => info, "conversation" => conversation.id}
      end

      params do
        requires :access_token, type:String
      end
      get '/sale_messages' do
        authorize
        messages = Array.new
        cars = Car.where(:dealer_code => current_user.dealer_number)
        cars.each do |car|
          car.conversations.each do |conv|
            messages << conv.messages.last
          end
        end
        {"status" => "success", "messages" => messages}
      end

      params do
        requires :access_token, type:String
      end
      get '/buy_messages' do
        authorize
        messages = Array.new
        cars_ids = Car.where(:dealer_code => current_user.dealer_number).collect(&:id)
        conversations = Conversation.where('sender_id = ? OR recipient_id = ? and car_id IS NOT NULL AND car_id not in (?)', current_user.id, current_user.id, cars_ids)
        conversations.each do |conv|
            #messages << conv.messages.last
            if !conv.messages.last.nil?
              messages << {'from' => conv.messages.last.user.name, 
                         'message' => conv.messages.last.body, 
                         'date' => conv.messages.last.created_at.strftime("%d %b  %Y at %I:%M%p"),
                         'car' => conv.car.make.to_s + " " + conv.car.model.to_s
                        }
            end
        end
        {"status" => "success", "messages" => messages}
      end

      params do
  	    requires :sel, type:Integer
  	    requires :msg, type:String
        optional :car, type:Integer
        requires :access_token, type:String
  	  end
      post '/' do
  	    authorize
  	    if User.exists?(params[:sel])
            car = nil
            car = params[:car] if !params[:car].nil? && !params[:car].empty?
            @conversation = Conversation.create_converstion(current_user.id, params[:sel], car)
            @message = @conversation.messages.build(:body => params[:msg])
      	    @message.user_id = current_user.id
  	
      		  recipient = Conversation.interlocutor(current_user, @conversation)
      		  @message.recipient = recipient.id
   	
     		  if @message.save!
     		  	PrivatePub.publish_to "/conversations/#{@conversation.id}", 
                                  :message => @message, 
                                  :conversation => @conversation,
                                  :user_id => @message.user.id,
                                  :sender_name => @message.user.name,
                                  :time => @message.created_at.strftime("%H:%M %p")
      		  {"status" => "success"}
      	  else 
      		  {"status" => "error"}
          end
      	end	
      end
	  	  
    end
  end
end
