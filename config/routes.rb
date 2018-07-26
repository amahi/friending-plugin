Friendings::Engine.routes.draw do
	# root of the plugin
	root :to => 'friendings#index'
	match 'requests' => 'friendings#requests',:via=> :all
end
