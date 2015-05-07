class Identicar
  require 'identicar'
  extend ActiveModel::Naming

  def self.makes()
    identicar = Identicar.new()
    result = identicar.makes
    return result['makes']
  end

  def self.series_and_models(make)
  	identicar = Identicar.new()
  	result = identicar.series_and_models(make)
  	return result
  end

  def self.vin(vin)
    identicar = Identicar.new()
    result = identicar.vin_search(vin)
    return result
  end
end
