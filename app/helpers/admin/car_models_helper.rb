module Admin::CarModelsHelper
	def show_series(model)
		series_name = ""
		series = CarsSeries.where('id=?', model.series_id).first
		series_name = series.name if !series.nil?
		return series_name
	end
end
