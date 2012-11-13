# @author Emmanuel Pastor/Nitish Upreti
class AssetGroupsController < PluginController
  unloadable
  before_filter :require_admin, :except => [:index, :show, :show_attachment, :show_image]

  # Lists all the [AssetGroup] from the Database.
  #
  # @return [AssetGroup] Array. 
  def index
    @asset_groups = AssetGroup.all
  end

  # Prepares a new [AssetGroup] object instance ready to be written into the Database.
  #
  # @return Nothing.
  def new
    @asset_group = AssetGroup.new
    @asset_id =  params[:asset_id]
    @referer = "new_asset_group"
    render 'new', :layout=>false        
  end

  # Creates a new [AssetGroup] in the Database.
  #
  # @return Nothing.
  def create
    asset_group = AssetGroup.create params[:asset_group]
    if params[:asset_id] != nil && params[:asset_id] != ''
      @asset = Asset.find_by_id params[:asset_id]
      @asset.asset_group = asset_group
      @asset.save
    else
      @asset = Asset.new
    end
    respond_to do |format|
      format.html  
      format.js
    end    
  end

  # Deletes an [AssetGroup] from the Database.
  #
  # @return Nothing.
  def delete
    asset_group = AssetGroup.find_by_id params[:id]
    assets = Asset.find_all_by_asset_group_id asset_group.id
    assets.each do |a|
      a.asset_group_id = nil
      a.save
    end
    asset_group.destroy

    #Populating the lists again so as the UI can be updated accordingly
    @favourites_asset, @favourites_asset_group = populate_favourite_list
    @assets, @asset_groups = populate_asset_list
    #render :partial => 'asset_types/assets_list', :layout => false, :locals => { :asset_types => AssetType.all, :user => User.current }
  end

  # Gets an [AssetGroup] from the Database, and displays it so the user can edit it.
  #
  # @return [AssetGroup].
  def edit
    @asset_group = AssetGroup.find_by_id params[:id]
  end

  # Retrieves an [AssetGroup] from the Database and displays its data.
  #
  # @return [AssetGroup].
  def show
    @asset_group = AssetGroup.find_by_id params[:id]
    @user = User.find_by_id session[:user_id]
       @reservations=Reservation.where("bookable_id = ? AND bookable_type = ? AND status <> ? AND is_recurring = ?",params[:id],'AssetGroup',Reservation::STATUS_CHECKED_IN,false)
    @recurring_reservations=Reservation.where("bookable_id = ? AND bookable_type = ? AND status <> ? AND is_recurring = ?",params[:id],'AssetGroup',Reservation::STATUS_CHECKED_IN,true)
  end

  # Saves the changes of an [AssetGroup] to the Database.
  #
  # @return Nothing.
  def update
    @asset_group = AssetGroup.find params[:id]
    @asset_group.update_attributes params[:asset_group]
    flash[:notice] = 'The group has been updated.'
    redirect_to :action => "index", :id => @asset_group
  end

  # Adds an [Asset] to an [AssetGroup].
  #
  # @return Nothing.
  def add_asset
    asset_group = AssetGroup.find params[:asset_group_id]
    asset = Asset.find params[:asset_id]
    asset.asset_group = asset_group
    asset.save
    @open_group = params[:asset_group_id]
  end

  # Displays an [Attachment] of an [AssetGroup].
  #
  # @return [Attachment].
  def show_attachment
    @attachment = Attachment.find_by_id params[:id]
    if @attachment != nil && (!@attachment.is_private || (@attachment.is_private && User.current.admin))
      send_file @attachment.diskfile, :filename => filename_for_content_disposition(@attachment.filename),
                                      :type => detect_content_type(@attachment),
                                      :disposition => (@attachment.image? ? 'inline' : 'attachment')
    else
      render_404
    end
  end

  # Saves changes to an [Attachment] of an [AssetGroup].
  #
  # @return Nothing.
   def edit_attachments
    @asset_group = AssetGroup.find_by_id params[:id]
    if request.post?
      attachment = Attachment.find_by_id params[:attachment][:id]
      attachment.description = params[:attachment][:description]
      attachment.save
      flash.now[:notice] = 'Your changes were saved.'
    end
   end

  # Adds a new [Attachment] to an [AssetGroup].
  #
  # @return Nothing.
  def add_attachment
    @asset_group = AssetGroup.find_by_id params[:id]

    if request.post?
      attachments = @asset_group.attach_files(params[:attachments])
      redirect_to :controller => 'asset_groups', :action => 'edit_attachments', :id => @asset_group
      return
    end
  end

  # Removes an [Attachment] from an [AssetGroup].
  #
  # @return Nothing.
  def remove_attachment
    attachment = Attachment.find_by_id params[:attachment_id]
    attachment.destroy
    @asset_group = AssetGroup.find_by_id params[:asset_group_id]
    flash[:notice] = "Attachment successfully destroyed."
    redirect_to :controller => 'asset_groups', :action => 'edit_attachments', :id => @asset_group
  end

  # Removes an [Asset] from an [AssetGroup].
  #
  # @return Nothing.
  def remove_asset
    asset = Asset.find_by_id params[:asset_id]
    asset.asset_group_id = nil
    asset.save
    @open_group = params[:id]
    @asset_group = AssetGroup.find_by_id params[:id]
    #render :partial => 'group_contents', :layout => false, :locals => { :asset_group => asset_group }
  end

  # Updates the Privacy of an [Attachment].
  #
  # @return Nothing.
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

  # Displays an Image in case the [Attachment] is one.
  #
  # @return A valid bin Image bitstream.
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


  private
    # Detects the content_type header of an [Attachment].
    #
    # @return a valid content_type header.
    def detect_content_type(attachment)
      content_type = attachment.content_type
      if content_type.blank?
        content_type = Redmine::MimeType.of(attachment.filename)
      end
      content_type.to_s
    end
end
