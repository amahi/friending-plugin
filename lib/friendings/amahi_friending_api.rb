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
		if self.duplicate_username(username)
			return "failed", {"message": "Username already exists."}
		end

		unless self.check_username_format(username)
			return "failed", {"message": "Invalid username format."}
		end

		url = "#{BASE_URL}/request"
		begin
			generated_pin = 5.times.map{rand(10)}.join
			response = RestClient.post(url, {"email": email, "pin": generated_pin}.to_json, headers={"Api-Key" => APIKEY, "content-type" => :json})

			json = JSON.parse(response)
			create_friend_user(email, username, generated_pin)
			return "success", json

		rescue RestClient::ExceptionWithResponse => err
			json = JSON.parse(err.response)
			return "failed", json
		end
	end

	def self.delete_friend_request(id)
		url = "#{BASE_URL}/request/#{id}"
		begin
			response = RestClient.delete(url, headers={"Api-Key" => APIKEY, "content-type" => :json})
			json = JSON.parse(response)
			return "success", json

		rescue RestClient::ExceptionWithResponse => err
			json = JSON.parse(err.response)
			return "failed", json
		end
	end

	def self.create_friend_user(email, username, pin)
		user = User.new({login: username, pin: pin, name: username, password: '12345678', password_confirmation: '12345678', remote_user: email})
		user.save
	end

	def self.duplicate_username(username)
		user = User.where({login: username}).first
		!(user.blank?)
	end

	def self.check_username_format(username)
		!(username.blank? or (username.length < 3 or username.length > 32) or !(username =~ /\A[A-Za-z][A-Za-z0-9]+\z/))
	end

end
