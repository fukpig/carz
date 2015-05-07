json.status @status
json.id @car.id
json.html button_tag "Follow", class: "btn btn-block btn-info follow-car", data: { url: follow_car_path(@car) }