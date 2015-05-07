json.array!(@cars) do |car|
  json.extract! car, :id, :client, :make, :stock, :model, :manufacture_year, :series, :badge, :door, :body, :seat, :user_id, :status, :rating, :image
  json.url car_url(car, format: :json)
end
