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

	def delete_user
		# todo
	end
end
