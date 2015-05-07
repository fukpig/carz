class CarsModel < ActiveRecord::Base
  #has_one :cars_series, foreign_key: 'series_id'
  belongs_to :cars_series, foreign_key: 'series_id'
  belongs_to :cars_make, foreign_key: 'series_id'

  def self.get_models(series)
  	models_arr = Array.new
  	series.each do |s|
  		series = CarsSeries.where("name = ?", s).first
  		models = CarsModel.where('series_id = ?', series.id)
  		models.map{|m| models_arr << m}
  	end
  	return models_arr
  end
end
