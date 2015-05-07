class Conversation < ActiveRecord::Base
  belongs_to :sender, :foreign_key => :sender_id, class_name: 'User'
  belongs_to :car
  belongs_to :recipient, :foreign_key => :recipient_id, class_name: 'User'

  has_many :messages, dependent: :destroy
  
  scope :involving, -> (user) do
    where("conversations.sender_id =? OR conversations.recipient_id =?",user.id,user.id)
  end

  scope :between, -> (sender_id,recipient_id,car_id) do
    where("(conversations.sender_id = ? AND conversations.recipient_id = ? AND conversations.car_id = ?) OR (conversations.sender_id = ? AND conversations.recipient_id =?  AND conversations.car_id = ?)", sender_id,recipient_id, car_id, recipient_id, sender_id, car_id)
  end
  
  def self.interlocutor(current_user, conversation)
    current_user == conversation.recipient ? conversation.sender : conversation.recipient
  end

  def self.create_converstion(sender_id, recipient_id, car_id)
    if Conversation.between(sender_id, recipient_id, car_id).present?
      conversation = Conversation.between(sender_id, recipient_id, car_id).first
    else
      conversation = Conversation.create!(:sender_id => sender_id, :recipient_id => recipient_id, :car_id => car_id)
    end
    return conversation
  end
end
