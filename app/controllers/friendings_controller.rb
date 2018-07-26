class FriendingsController < ApplicationController
	before_action :admin_required

	def index
		@page_title = t('friend_users')
	end

	def requests
		@page_title = t('requests')
	end
end
