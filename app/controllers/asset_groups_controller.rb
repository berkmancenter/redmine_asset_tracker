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

   def edit_attachments
    @asset_group = AssetGroup.find_by_id params[:id]
    if request.post?
      attachment = Attachment.find_by_id params[:attachment][:id]
      attachment.description = params[:attachment][:description]
      attachment.save
      flash.now[:notice] = 'Your changes were saved.'
    end
   end

  def add_attachment
    @asset_group = AssetGroup.find_by_id params[:id]

    if request.post?
      attachments = @asset_group.attach_files(params[:attachments])
      redirect_to :controller => 'asset_groups', :action => 'edit_attachments', :id => @asset_group
      return
    end
  end

  def remove_attachment
    attachment = Attachment.find_by_id params[:attachment_id]
    attachment.destroy
    @asset_group = AssetGroup.find_by_id params[:asset_group_id]
    flash[:notice] = "Attachment successfully destroyed."
    redirect_to :controller => 'asset_groups', :action => 'edit_attachments', :id => @asset_group
  end

  def change_attachment_privacy
    attachment = Attachment.find_by_id params[:attachment_id]
    if attachment.is_private
      attachment.is_private =false
    else
      attachment.is_private = true
    end
    attachment.save
    @asset_group = AssetGroup.find_by_id params[:asset_group_id]
    flash[:notice] = "Privacy settings updated."
    redirect_to :controller => 'asset_groups', :action => 'edit_attachments', :id => @asset_group
  end

  def show_image
    asset_group = AssetGroup.find_by_id params[:id]
    if asset_group != nil
      has_image=false;
      asset_group.attachments.each do |a|
        if a != nil && a.image? && !a.is_private
          send_file a.diskfile, :filename => filename_for_content_disposition(a.filename),
                                          :type => detect_content_type(a),
                                          :disposition => (a.image? ? 'inline' : 'attachment')
          has_image = true
          return
        end
      end
      if !has_image
          redirect_to "/plugin_assets/redmine_asset_tracker/images/add_photo.gif"
      end
    end
  end
end
