require "friendings/amahi_friending_api.rb"

class FriendingsController < ApplicationController
	before_action :admin_required

	def index
		@page_title = t('friend_users')
		@status, @users = AmahiFriendingApi.get_friend_users
	end

	def requests
		@page_title = t('requests')
		@status, @requests = AmahiFriendingApi.get_friend_requests
	end

	def create_friend_request
		if params[:email].blank? or params[:username].blank?
			render :json => {success: false, message: 'Field values are missing'}
			return
		end

		status, data = AmahiFriendingApi.post_friend_request(params[:email], params[:username])
		if status == "success"
			parsed_last_request_time = DateTime.parse(data["last_requested_at"]).strftime('%a, %d %b %Y %H:%M:%S')

			render :json => data.merge({success: true, message: "Request submitted successfully", 
				parsed_time: parsed_last_request_time})
		else
			render :json => data.merge({success: false})
		end
	end

	def delete_user
		#
	end

	def delete_friend_request
		status, data = AmahiFriendingApi.delete_friend_request(params[:id], params[:email])
		render :json => data.merge({success: status == "success", id: params[:id]})
	end
end
