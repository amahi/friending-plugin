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

			remote_users = User.where.not({remote_user:nil})
			mapping = {}
			remote_users.each do |user|
				mapping[user.remote_user] = user.login
			end

			json.each do |user|
				email = user["amahi_user"]["email"]
				if mapping[email].blank?
					# create NAU using generated username (fix this)
					generated_username = email[0..email.index("@")-1]
					user["amahi_user"]["username"] = generated_username + "5234"
				else
					user["amahi_user"]["username"] = mapping[email]
				end
			end

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

	def self.delete_friend_request(id, email = nil)
		url = "#{BASE_URL}/request/#{id}"
		begin
			response = RestClient.delete(url, headers={"Api-Key" => APIKEY, "content-type" => :json})
			json = JSON.parse(response)

			unless email.blank?
				user = User.where({remote_user: email}).first
				user.delete unless user.blank?
			end

			return "success", json

		rescue RestClient::ExceptionWithResponse => err
			json = JSON.parse(err.response)
			return "failed", json
		end
	end

	def self.create_friend_user(email, username, pin)
		generated_password = rand(36**8).to_s(36)
		user = User.new({login: username, pin: pin, name: username, password: generated_password, password_confirmation: generated_password, remote_user: email})
		user.save
	end

	def self.duplicate_username(username)
		user = User.where({login: username}).first
		!(user.blank?)
	end

	def self.check_username_format(username)
		!(username.blank? or (username.length < 3 or username.length > 32) or !(username =~ /\A[A-Za-z][A-Za-z0-9]+\z/))
	end

	def self.delete_user(user_id, email)
		url = "#{BASE_URL}/user/#{user_id}"
		begin
			response = RestClient.delete(url, headers={"Api-Key" => APIKEY, "content-type" => :json})
			json = JSON.parse(response)

			unless email.blank?
				user = User.where({remote_user: email}).first
				user.delete unless user.blank?
			end

			return "success", json

		rescue RestClient::ExceptionWithResponse => err
			json = JSON.parse(err.response)
			return "failed", json
		end
	end

	def self.update_share_permission(share_id, user_id, accessable, writable)
		unless accessable.blank?
			Share.find(share_id).toggle_access!(user_id)
		end

		unless writable.blank?
			Share.find(share_id).toggle_write!(user_id)
		end
	end

end
