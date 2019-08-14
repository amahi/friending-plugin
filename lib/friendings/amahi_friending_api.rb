require 'open-uri'
require 'json'
require 'rest-client'

class AmahiFriendingApi
	BASE_URL = "http://127.0.0.1:5000/frnd"
	APIKEY = Setting.where({name: "api-key"}).first.value

	# fetch friend users from Amahi.org friending API
	# if new users fetched, then create corresponding local HDA users
	# if user present on HDA but not on fetched users list then delete that user from HDA
	# also fetch updated users timely by running script which request Amahi.org APIs
	def self.get_friend_users
		url = "#{BASE_URL}/users"
		begin
			response = RestClient.get(url, headers={"api-key" => APIKEY})
			json = JSON.parse(response)

			return json["message"], [] unless json["success"]

			# remote_user column in HDA is used for distinguishing friend users from normal HDA users
			# if remote_user column for a particular user is not nil and contains email address as a
			# string then it means that this user is a friend user
			local_users = User.where.not({remote_user:nil})

			data = []
			mapping = {}  # email -> NAU

			local_users.each do |user|
				mapping[user.remote_user] = user
			end

			fetched_users = json["data"]
			fetched_users.each do |user|
				email = user["email"]

				if mapping[email].blank?
					# case when new friend request got accepted and so new user needs to be created on HDA
					friend_request = FriendRequest.where({email: email}).first
					next if friend_request.blank?
					friend_request.status = 2
					friend_request.status_txt = "Accepted"
					friend_request.save

					username = friend_request.username
					status, saved_user_id = create_friend_user(email, username, friend_request.pin)

					if status
						user["username"] = username
						user["local_id"] = saved_user_id
						user["type"] = "accepted"
						data << user
					end

				else
					# case when remote user is present as NAU on platform
					user["username"] = mapping[email].login
					user["local_id"] = mapping[email].id
					user["type"] = "accepted"
					mapping.delete(email)
					data << user
				end
			end

			# case when user is locally present but not present on Amahi.org, in this case
			# local user needs to be deleted from HDA
			fetched_users_emails = []
			fetched_users.each { |f_user| fetched_users_emails << f_user["email"] }

			local_users_emails = []
			local_users.each { |l_user| local_users_emails << l_user.remote_user }

			# email ids for which corresponding user needs to be deleted from HDA
			non_user_email_ids = local_users_emails - fetched_users_emails
			users_to_be_deleted = User.where({remote_user: non_user_email_ids})
			users_to_be_deleted.delete_all unless users_to_be_deleted.blank?

			# Also deleting corresponding friend request from friend_requests table on HDA
			friend_requests_to_be_deleted = FriendRequest.where({email: non_user_email_ids})
			friend_requests_to_be_deleted.delete_all unless friend_requests_to_be_deleted.blank?

			return "success", data

		rescue Errno::EHOSTUNREACH
			return "host_unreachable", []

		rescue Errno::ECONNREFUSED
			return "host_unreachable", []

		rescue RestClient::ExceptionWithResponse => err
			err.response
			return "failed", []
		end
	end

	def self.get_friend_requests
		url = "#{BASE_URL}/requests"
		begin
			response = RestClient.get(url, headers={"api-key" => APIKEY})
			json = JSON.parse(response)

			return json["message"], [] unless json["success"]
			return "success", json["data"]

		rescue Errno::EHOSTUNREACH
			return "host_unreachable", []

		rescue Errno::ECONNREFUSED
			return "host_unreachable", []

		rescue RestClient::ExceptionWithResponse => err
			err.response
			return "failed", []
		end
	end

	def self.post_friend_request(email, username)
		if self.duplicate_username(username)
			return false, {"message": "Username already exists."}
		end

		unless self.check_username_format(username)
			return false, {"message": "Invalid username format."}
		end

		url = "#{BASE_URL}/request"
		begin
			generated_pin = 5.times.map{rand(10)}.join
			response = RestClient.post(url, {"email": email, "pin": generated_pin}.to_json, headers={"api-key" => APIKEY, "content-type" => :json})

			json = JSON.parse(response)

			if json["success"]
			    save_request_to_hda(json, username)
			end

			return json["success"], json

		rescue RestClient::ExceptionWithResponse => err
			json = JSON.parse(err.response)
			return false, json
		end
	end

	def self.save_request_to_hda(response, username)
		friend_request_data = response["request"]
		hda_friend_request = FriendRequest.new(friend_request_data)
		hda_friend_request.username = username
		hda_friend_request.save
	end

	def self.delete_friend_request(id, email = nil)
		url = "#{BASE_URL}/request/#{id}"
		begin
			response = RestClient.delete(url, headers={"api-key" => APIKEY, "content-type" => :json})
			json = JSON.parse(response)

			request = FriendRequest.where({email: email}).first
			request.delete unless request.blank?

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
		status = user.save
		return status, user.id
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
			response = RestClient.delete(url, headers={"api-key" => APIKEY, "content-type" => :json})
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

	def self.update_share_permission(share_id, user_id, type)
		user = User.find(user_id)
		share = Share.find(share_id)

		if type == "access"
			share.toggle_access!(user.id)
			return share.users_with_share_access.include?(user)
		else
			share.toggle_write!(user.id)
			return share.users_with_write_access.include?(user)
		end
	end

	def self.resend_friend_request(request_id)
		url = "#{BASE_URL}/request/#{request_id}/resend"
		begin
			response = RestClient.put(url, {}, headers={"api-key" => APIKEY, "content-type" => :json})
			json = JSON.parse(response)

			return "success", json

		rescue RestClient::ExceptionWithResponse => err
			json = JSON.parse(err.response)
			return "failed", json
		end
	end

end
