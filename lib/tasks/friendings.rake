
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

			# case 1: if friend user present on Amahi.org but not on local HDA
			# then add this friend user to HDA
			# case 2: if friend user is not present on Amahi.org but present on
			# local HDA then delete that user from HDA

			sql_query = "SELECT * FROM users where remote_user IS NOT NULL;"
			local_users = ActiveRecord::Base.connection.execute(sql_query)

			mapping = {}
			local_users.each do |user|
				email = user[17]
				mapping[email] = user
			end

			fetched_friend_users.each do |user|
				email = user["email"]

				if mapping[email].blank?
					# case when new friend request got accepted and so new user needs to be created on HDA
					sql_query = "SELECT * FROM friend_requests where email='#{email}';"
					friend_request = ActiveRecord::Base.connection.execute(sql_query)

					next if friend_request.count == 0
					update_query = "UPDATE friend_requests SET status=2, status_txt='Accepted' where id=#{friend_request.first[0]};"

					username = friend_request.first[9]
					generated_password = rand(36**8).to_s(36)

					password_salt = rand(36**20).to_s(36)
					crypted_password = rand(36**128).to_s(36)
					persistence_token = rand(36**128).to_s(36)

					current_time = Time.now().strftime('%Y-%m-%d %H:%M:%S')

					# save friend user to HDA database
					insert_query = "INSERT INTO users(login, pin, name, password_salt, crypted_password, persistence_token, remote_user, login_count, created_at, updated_at) VALUES('#{username}', #{friend_request.first[4]}, '#{username}', '#{password_salt}', '#{crypted_password}', '#{persistence_token}', '#{email}', 0, '#{current_time}', '#{current_time}');"
					ActiveRecord::Base.connection.execute(insert_query)

				end
			end
		end
	end
end
