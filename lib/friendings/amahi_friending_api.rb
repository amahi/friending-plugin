require 'open-uri'
require 'json'

class AmahiFriendingApi
	BASE_URL = "http://66.165.251.200:8877"
	APIKEY = Setting.where({name: "api-key"}).first.value

	def self.get_friend_users
		url = "#{BASE_URL}/api/frnd/users"
		begin
			temp = open(url, "Api-Key" => APIKEY)
			result = JSON.parse(temp.read)
			return "success", result

		rescue OpenURI::HTTPError => error
			response = error.io
			status = response.status
			return "failed", []
		end
	end

	def self.get_friend_requests
		url = "#{BASE_URL}/api/frnd/requests"
		begin
			temp = open(url, "Api-Key" => APIKEY)
			result = JSON.parse(temp.read)
			return "success", result

		rescue OpenURI::HTTPError => error
			response = error.io
			status = response.status
			return "failed", []
		end
	end

end
