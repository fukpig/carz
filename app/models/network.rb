class Network < ActiveRecord::Base
  belongs_to :user
  belongs_to :member, :class_name => "User"

  
  def self.get_all_members(user)
  	networks = Network.where('user_id =? OR member_id =?', user.id, user.id)
  	members = Array.new
  	networks.each do |network|
  	  user = network.user_id == user.id ? network.member : network.user
  	  members << user
  	end
  	return members
  end
end
