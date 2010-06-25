require 'redmine'
Redmine::Plugin.register :redmine_asset_tracker do
  name 'Redmine Asset Tracker plugin'
  author 'Emmanuel Pastor'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  menu :application_menu, :asset_types, { :controller => 'asset_types', :action => 'index' }, :caption => 'Assets'
  #permission :view_assets, :assets => :index
  #permission :create_assets, :assets => :new
  #permission :edit_assets, :assets => :edit

    # This plugin should be reloaded in development mode.
  if RAILS_ENV == 'development'
    ActiveSupport::Dependencies.load_once_paths.reject!{|x| x =~ /^#{Regexp.escape(File.dirname(__FILE__))}/}
    end
end
