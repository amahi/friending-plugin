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
			render :json => {success: false, message: t('missing_field_values')}
			return
		end

		status, data = AmahiFriendingApi.post_friend_request(params[:email], params[:username])
		if status == "success"
			parsed_last_request_time = DateTime.parse(data["last_requested_at"]).strftime('%a, %d %b %Y %H:%M:%S')

			render :json => data.merge({success: true, message: t('request_submitted_successfully'),
				parsed_time: parsed_last_request_time})
		else
			render :json => data.merge({success: false})
		end
	end

	def delete_friend_request
		status, data = AmahiFriendingApi.delete_friend_request(params[:id], params[:email])
		render :json => data.merge({success: status == "success", id: params[:id]})
	end

	def delete_user
		status, data = AmahiFriendingApi.delete_user(params[:id], params[:email], params[:type])
		render :json => data.merge({success: status == "success", id: params[:id], email: params[:email]})
	end

	def toggle_share_access
		updated_value = AmahiFriendingApi.update_share_permission(params[:share_id], params[:user_id], params[:type])
		render :json => {success: true, share_id: params[:share_id], type: params[:type], user_id: params[:user_id], updated_value: updated_value}
	end

	def resend_friend_request
		status, data = AmahiFriendingApi.resend_friend_request(params[:id])
		readable_last_request_at = DateTime.parse(Time.now.to_s).strftime('%a, %d %b %Y %H:%M:%S')
		render :json => data.merge({success: status == "success", id: params[:id], last_request_at: readable_last_request_at})
	end
end
