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

		status = AmahiFriendingApi.post_friend_request(params[:email], params[:username])
		if status == "success"
			render :json => {success: true, message: 'Request submitted successfully'}
		else
			render :json => {success: false, message: 'Some error occurred'}
		end
	end

	def delete_user
		# todo
	end
end
