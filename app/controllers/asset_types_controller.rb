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
    @asset_id =  params[:asset_id]
    @referer = params[:referer]
    render 'new', :layout=>false
  end

  def create
    @asset_type = AssetType.create params[:asset_type]
    @referer = params[:referer]
    if params[:asset_id] && !params[:asset_id].empty?
      @asset = Asset.find_by_id params[:asset_id]
      @asset.asset_type = @asset_type
      @asset.save
    else
      @asset = Asset.new
    end
    respond_to do |format|
      format.html
      format.js
    end
  end

  def delete
    asset_type = AssetType.find_by_id params[:id]
    assets = Asset.find_all_by_asset_type_id asset_type.id
    if assets.empty?
      asset_type.delete
      flash[:notice] = 'The asset category has been deleted.'
    else
      flash[:error] = 'The asset category was not deleted. Please delete or move to a different category all the assets archived under this category first.'
    end
    redirect_to :controller => 'asset_types', :action => 'index'
  end

  def edit
    @asset_type = AssetType.find_by_id params[:id]
  end

  def update
    @asset_type = AssetType.find params[:id]
    @asset_type.update_attributes params[:asset_type]
    flash[:notice] = 'The asset category has been updated.'
    redirect_to :action => "index", :id => @asset_type
  end
   
end