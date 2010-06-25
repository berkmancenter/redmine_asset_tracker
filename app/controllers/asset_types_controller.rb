class AssetTypesController < ApplicationController
  unloadable
  helper :custom_fields
  include CustomFieldsHelper
  before_filter :require_admin, :except => :index

  def index
    @asset_types = AssetType.find :all
    @user = User.find_by_id session[:user_id]
  end

  def new
    @asset_type = AssetType.new
  end

  def create
    @asset_type = AssetType.create params[:asset_type]
    redirect_to :controller => 'assets', :action => 'new'
  end

  def edit
    @asset_type = AssetType.find_by_id params[:id]
  end

   
end