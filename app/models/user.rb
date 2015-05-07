class User < ActiveRecord::Base
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :omniauth_providers => [:facebook]

  after_invitation_accepted :create_network

  before_save :ensure_authentication_token
  has_one :subscription
  has_many :setandforget, dependent: :destroy
  has_many :networks, dependent: :destroy
  has_many :network_members, :through => :networks
  has_many :inverse_networks, :class_name => "Network", :foreign_key => "member_id", dependent: :destroy
  has_many :inverse_networks_members, :through => :inverse_networks, :source => :user
  has_many :followed, :class_name => 'FollowedCar'
  has_many :followed_cars, :through => :followed, :source => :car, :class_name => 'Car'
  has_many :cars, :foreign_key => "dealer_code", :primary_key => "dealer_number"
  belongs_to :role

  acts_as_reader

  has_many :conversations, :foreign_key => :sender_id

  has_attached_file :avatar
  validates_attachment_content_type :avatar, :content_type => %w(image/jpeg image/jpg image/png)

  scope :involving, -> (user) do
    where("conversations.sender_id =? OR conversations.recipient_id =?",user.id,user.id)
  end
 
  scope :between, -> (sender_id,recipient_id) do
    where("(conversations.sender_id = ? AND conversations.recipient_id =?) OR (conversations.sender_id = ? AND conversations.recipient_id =?)", sender_id,recipient_id, recipient_id, sender_id)
  end
  
  def self.from_omniauth(auth)
	  where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
		user.email = auth.info.email
		user.password = Devise.friendly_token[0,20]
		user.name = auth.info.name  
	  end
  end
  
  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
  end

  def create_network
    inviter = User.find(self.invited_by_id)
    inviter.networks.build(:member_id => self.id)
    inviter.save
  end


  def ensure_authentication_token
    self.authentication_token ||= generate_authentication_token
  end

  def decode_image_data(image_data)
    if image_data.present?
      data = StringIO.new(Base64.decode64(image_data))
      data.class.class_eval {attr_accessor :original_filename, :content_type}
      data.original_filename = self.id.to_s + ".jpg"
      data.content_type = "image/jpg"
      self.avatar = data
      self.save!
    end
  end


  private

  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.where(authentication_token: token).first
    end
  end

end