module SetandforgetHelper
	def set_default(option)
		default = ''
		if !params[:search].nil?
			  default = params[:search][option]
		end

		return default
	end

	def build_series_option(series, defaults)
		selected =  defaults.include?(series['name']) ? true : false
    content_tag(:option, "#{series['name']} ALL", class: ["series_category"], value: series['name'], selected: selected)
	end

	def build_model_option(model, defaults)
		selected =  defaults.include?(model['name']) ? true : false
		content_tag(:option, model['name'], class: ["item"], value: model['name'], selected: selected)
	end
end
