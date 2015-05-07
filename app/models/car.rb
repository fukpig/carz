class Car < ActiveRecord::Base
  after_save ThinkingSphinx::RealTime.callback_for(:car), :check_search
  mount_uploader :image, CarUploader
  has_many :images
  belongs_to :user, :foreign_key => :dealer_code, class_name: 'User'
  has_many :conversations
  has_paper_trail 
   
  def self.get_unique(cars)
	  filters = Array.new
	  info = Hash.new
	  Car.columns.map {|c| filters << c.name if !['id', 'comments', 'options', 'sync', 'image'].include?(c.name) }
	  filters.each do |filter|
	    info[filter] = Array.new
		  cars.each do |car|
		    info[filter] << car[filter] if !car[filter].nil?
		  end
		  info[filter] = info[filter].uniq.sort
	  end
	  return info
  end

  def check_search
   	snfs = Setandforget.all
   	snfs.each do |snf|
   		params = Hash.new
   		params[:search] = JSON.parse snf.search_params
   		with_params = with_params(params)
   		cars = Car.search "", :conditions => search_params(params), :with => with_params, :per_page => 500
		  if cars.include?(self)
  			user = User.find(snf.user_id)
			 SnfMailer.alert(user, self).deliver
		  end
   	end
  end
end
