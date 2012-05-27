RedmineApp::Application.routes.draw do 

	match 'asset_groups(/:action(/:id))', :controller => 'asset_groups'
	match 'asset_types(/:action(/:id))', :controller => 'asset_types'
	match 'assets(/:action(/:id))', :controller => 'assets'
	match 'reservations(/:action(/:id))', :controller => 'reservations'
end
