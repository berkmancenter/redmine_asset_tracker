class AssetGroupsController < ApplicationController
  unloadable
  before_filter :require_admin
  def index
    @asset_groups = AssetGroup.all
  end
  def new
    @asset_group = AssetGroup.new
    @asset_id =  params[:asset_id]
  end

  def create
    @asset_group = AssetGroup.create params[:asset_group]
    if params[:asset_id] == nil
      redirect_to :controller => 'assets', :action => 'new'
    else
      @asset = Asset.find_by_id params[:asset_id]
      @asset.asset_group = @asset_group
      @asset.save
      redirect_to :controller => 'assets', :action => 'edit', :id => @asset
    end
  end

  def delete
    asset_group = AssetGroup.find_by_id params[:id]
    assets = Asset.find_all_by_asset_group_id asset_group.id
    assets.each do |a|
      a.asset_group_id = nil
      a.save
    end
    asset_group.delete
    flash[:notice] = 'The group has been deleted. All the assets that belonged to it are now group-less.'
    redirect_to :controller => 'asset_groups', :action => 'index'
  end

  def edit
    @asset_group = AssetGroup.find_by_id params[:id]
  end

  def update
    @asset_group = AssetGroup.find params[:id]
    @asset_group.update_attributes params[:asset_group]
    flash[:notice] = 'The group has been updated.'
    redirect_to :action => "index", :id => @asset_group
  end
end
