require 'redmine'

Redmine::Plugin.register :redmine_asset_tracker do
  name 'Redmine Asset Tracker plugin'
  author 'Emmanuel Pastor / Nitish Upreti'
  description 'An asset tracker plugin for Redmine'
  version '0.0.1'
  menu :application_menu, :asset_types, { :controller => 'asset_types', :action => 'index' }, :caption => 'Assets List'
  menu :application_menu, :reservations, { :controller => 'reservations', :action => 'index' }, :caption => 'Reservations'
  menu :application_menu, :history, { :controller => 'reservations', :action => 'history' }, :caption => 'History'
end

Redmine::Plugin.find(:redmine_asset_tracker).requires_redmine(:version_or_higher=>'2.0.0')