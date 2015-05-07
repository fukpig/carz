class CarsSeries < ActiveRecord::Base
  belongs_to :cars_make
  has_many :cars_models, foreign_key: 'series_id'

  def self.get_series(make)
  	make = CarsMake.where('name = ?', make).first
  	CarsSeries.where('make_id = ?', make.id)
  end
end
