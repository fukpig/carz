json.array!(@users) do |user|
  json.extract! user, :id, :name, :provider, :url
  json.url user_url(user, format: :json)
end
