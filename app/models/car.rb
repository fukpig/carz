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

  def self.search_params(params={})
    search_conditions = ""
    p = params[:search].dup
    p.each do |k,v|
      if !k.to_s.include?("_from") && !k.to_s.include?("_to")
        if v.kind_of?(Array)
          values_string = v.join('|')
        else 
          values_string = v
        end
        params_string = "(@" + k.to_s + " " + values_string + ")"
        search_conditions = search_conditions + params_string
      end
    end
    return search_conditions
  end

  def with_params(params={})
    return {} if params.blank? || params[:search].blank?
    info = Hash.new
    params[:search].each do |k, v|
      if k.to_s.include? "_from"
        param_f = v
        param_f = 0 if param_f.empty?
           
        param_name = k.to_s.gsub("_from", "")
        param_t = params[:search][param_name+"_to"]
        param_t = 99999 if param_t.empty?
        info[param_name] = param_f.to_i..param_t.to_i
      end
    end
    return info
  end
end
