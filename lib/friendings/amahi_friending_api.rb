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
			fetched_users = JSON.parse(response)

			local_users = User.where.not({remote_user:nil})

			data = []
			mapping = {}  # email -> NAU

			local_users.each do |user|
				mapping[user.remote_user] = user
			end

			fetched_users.each do |user|
				email = user["amahi_user"]["email"]

				if mapping[email].blank?
					# case when NAU is deleted by admin and so probably admin do not want this
					# NAU as friend user and thus this user needs to be deleted from amahi.org

					self.delete_user(user["amahi_user"]["id"], nil)

				else
					# case when remote user is present as NAU on platform
					user["amahi_user"]["username"] = mapping[email].login
					user["amahi_user"]["local_id"] = mapping[email].id
					user["amahi_user"]["type"] = "accepted"

					mapping.delete(email)

					data << user
				end
			end

			# case when NAU is present but that user is not present on amahi.org, this is possible
			# when friend request is currently active and waiting for acceptance or it gets expired
			mapping.each do |mapped_user|
				user = mapped_user[1]
				obj = {}
				obj["id"] = user.id
				obj["created_at"] = user.created_at.to_s
				obj["amahi_user"] = {}
				obj["amahi_user"]["id"] = user.id
				obj["amahi_user"]["created_at"] = user.created_at.to_s
				obj["amahi_user"]["email"] = user.remote_user
				obj["amahi_user"]["username"] = user.login
				obj["amahi_user"]["local_id"] = user.id
				obj["amahi_user"]["type"] = "stale"

				data << obj
			end

			return "success", data

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

	def self.delete_user(user_id, email, type)
		url = "#{BASE_URL}/user/#{user_id}"

		if type == "stale"
			unless email.blank?
				user = User.where({remote_user: email}).first
				user.delete unless user.blank?
			end
			return "success", {}
		end

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

	def self.update_share_permission(share_id, user_id, type) #user_id is wrong, create user if local user not exist
		user = User.find(user_id)
		share = Share.find(share_id)

		if type == "access"
			# Share.find(share_id).toggle_access!(user_id)
			if share.users_with_share_access.include?(user.id)
				share.users_with_share_access -= [user]
			else
				share.users_with_share_access += [user]
			end
		else
			# Share.find(share_id).toggle_write!(user_id)
			if share.users_with_write_access.include?(user.id)
				share.users_with_write_access -= [user]
			else
				share.users_with_write_access += [user]
			end
		end

		share.save!
	end

	def self.resend_friend_request(request_id)
		url = "#{BASE_URL}/request/#{request_id}/resend"
		begin
			response = RestClient.put(url, {}, headers={"Api-Key" => APIKEY, "content-type" => :json})
			json = JSON.parse(response)

			return "success", json

		rescue RestClient::ExceptionWithResponse => err
			json = JSON.parse(err.response)
			return "failed", json
		end
	end

end
