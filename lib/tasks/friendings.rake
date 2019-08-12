
namespace :friendings do
	BASE_URL = "http://127.0.0.1:5000/frnd"

	desc "Sync friend users with Amahi.org"
	task :update_friend_users => :environment do
		url = "#{BASE_URL}/users"
		begin
			sql_query = "SELECT value FROM settings where name='api-key';"
			api_key = ActiveRecord::Base.connection.execute(sql_query)
			api_key = api_key.first.first

			response = RestClient.get(url, headers={"api-key" => api_key})
			output = JSON.parse(response)
			fetched_friend_users = output["data"]

			puts ">>>>>>>>>>>>> >>>>>>>>>>>>"
			puts fetched_friend_users.as_json

			# case 1: if friend user present on Amahi.org but not on local HDA
			# then add this friend user to HDA
			# case 2: if friend user is not present on Amahi.org but present on
			# local HDA then delete that user from HDA

			sql_query = "SELECT * FROM users where remote_user IS NOT NULL;"
			local_users = ActiveRecord::Base.connection.execute(sql_query)

			puts ">>>>>>>>>>> >>>>>>>>>"
			puts local_users.as_json

			mapping = {}
			local_users.each do |user|
				email = user[17]
				mapping[email] = user
			end

			fetched_friend_users.each do |user|
				email = user["email"]

				if mapping[email].blank?
					# case when new friend request got accepted and so new user needs to be created on HDA
					sql_query = "SELECT * FROM friend_requests where remote_user = '#{email}';"
					friend_request = ActiveRecord::Base.connection.execute(sql_query)
					next if friend_request.blank?
					# friend_request.status = 2 #accepted
					# username = friend_request.username
					# create_friend_user(email, username, user["pin"])
				end
			end

		end
	end

end
