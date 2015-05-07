module ApplicationHelper
  def unread_messages_count
    Message.where('recipient = ?', current_user.id).unread_by(current_user).count
  end
end
