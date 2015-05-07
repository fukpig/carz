class MessagesController < ApplicationController
  skip_before_action :verify_authenticity_token
 
  def unread
    @messages = Message.where('recipient = ?', current_user.id).unread_by(current_user)
  end 
 
  def create
    authenticate_user!
    @conversation = Conversation.find(params[:conversation_id])
    @message = @conversation.messages.build(message_params)
    @message.user_id = current_user.id
	
	  recipient = Conversation.interlocutor(current_user, @conversation)
	  @message.recipient = recipient.id
    @message.save!
 
    @path = conversation_path(@conversation)
	  render layout: false
  end
  
  def read
    authenticate_user!
	  conversation = Conversation.find(params[:conversation_id])
	  @message = conversation.messages.find(params[:message_id])
	  @message.mark_as_read! :for => current_user
	  render :json => { :status => "success" }
  end
 
  private

  def message_params
    params.require(:message).permit(:body)
  end
end