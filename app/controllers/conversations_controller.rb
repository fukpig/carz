class ConversationsController < ApplicationController
  layout false
  skip_before_action :verify_authenticity_token
  
  def create
    authenticate_user!
    @conversation = Conversation.create_converstion(params[:sender_id], params[:recipient_id])
    render json: { conversation_id: @conversation.id }
  end
 
  def show
    authenticate_user!
    @conversation = Conversation.find(params[:id])
    @reciever = Conversation.interlocutor(current_user, @conversation)
    @messages = @conversation.messages
	  @messages.where('recipient = ?', current_user.id).mark_as_read! :all, :for => current_user
    @message = Message.new
  end
 
  private
  def conversation_params
    params.permit(:sender_id, :recipient_id)
  end
 

end
