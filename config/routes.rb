Friendings::Engine.routes.draw do
	# root of the plugin
	root :to => 'friendings#index'
	match 'requests' => 'friendings#requests',:via=> :all
	post '/frnd/request' => 'friendings#create_friend_request', :as => 'create_friend_request'
	delete '/frnd' => 'friendings#delete_user', :as => 'delete_friend_user'
	delete '/frnd/request' => 'friendings#delete_friend_request', :as => 'delete_friend_request'
	post '/frnd/share' => 'friendings#toggle_share_access', :as => 'toggle_share_access'
	put '/frnd/request' => 'friendings#resend_friend_request', :as => 'resend_friend_request'
end
