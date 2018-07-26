Friendings::Engine.routes.draw do
	# root of the plugin
	root :to => 'friendings#index'
	match 'requests' => 'friendings#requests',:via=> :all
	delete '/frnd/:id' => 'friendings#delete_user', :as => 'delete_friend_user'
end
