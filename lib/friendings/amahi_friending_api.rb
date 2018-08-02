require 'open-uri'
require 'json'
require 'rest-client'

class AmahiFriendingApi
	BASE_URL = "http://66.165.251.200:8877/api/frnd"
	APIKEY = Setting.where({name: "api-key"}).first.value

	def self.get_friend_users
		url = "#{BASE_URL}/users"
		begin
			response = RestClient.get(url, headers={"Api-Key" => APIKEY})
			json = JSON.parse(response)
			return "success", json
		rescue RestClient::ExceptionWithResponse => err
			err.response
			return "failed", []
		end
	end

	def self.get_friend_requests
		url = "#{BASE_URL}/requests"
		begin
			response = RestClient.get(url, headers={"Api-Key" => APIKEY})
			json = JSON.parse(response)
			return "success", json
		rescue RestClient::ExceptionWithResponse => err
			err.response
			return "failed", []
		end
	end

	def self.post_friend_request(email, username)
		url = "#{BASE_URL}/request"
		begin
			generated_pin = 5.times.map{rand(10)}.join
			RestClient.post(url, {"email": email, "pin": generated_pin}.to_json, headers={"Api-Key" => APIKEY})
			# TODO: create NAU with provided username
			return "success"
		rescue RestClient::ExceptionWithResponse => err
			err.response
			return "failed"
		end
	end

end
