module CarsHelper
	def follow(car)
		if FollowedCar.where('car_id = ? and user_id = ?', car.id, current_user.id).first
			return true
		else
			return false
		end
	end
	def show_follow_button(car)
		button_tag "Follow", class: "btn btn-block btn-info follow-car", data: { url: follow_car_path(car) }
	end

	def show_unfollow_button(car)
		button_tag "Unfollow", class: "btn btn-block btn-info unfollow-car", data: { url: unfollow_car_path(car) }
	end
end
