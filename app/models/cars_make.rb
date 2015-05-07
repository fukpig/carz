class CarsMake < ActiveRecord::Base
  has_many :cars_series, foreign_key: 'make_id'
  has_many :cars_models, foreign_key: 'make_id'

  def self.get_makes
  	CarsMake.all
  end

end
