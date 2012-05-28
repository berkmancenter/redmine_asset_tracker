# @author Emmanuel Pastor/Nitish Upreti
class AssetsController < ApplicationController
  unloadable
  helper :custom_fields
  include CustomFieldsHelper
  before_filter :require_admin, :except => [:index, :show, :show_attachment, :show_image]

  # Lists all the Assets from the DB.
  #
  # @return [Asset] array.
  def index
    @assets = Asset.find:all
  end

  # Displays an Asset from the DB.
  #
  # @return [Asset].
  def show
    @asset = Asset.find_by_id params[:id]
    @user = User.find_by_id session[:user_id]
  end

  # Creates a new Asset Instance, ready to be saved to the DB.
  #
  # @return [Asset].
  def new
    @asset = Asset.new
  end

  # Saves an Asset to the DB.
  #
  # @return Nothing.
  def create
    @asset = Asset.create params[:asset]
    redirect_to :action => "edit", :id => @asset
  end

  # Clones an existing Asset from the DB.
  #
  # @return [Asset].
  def clone
    existing_asset = Asset.find_by_id params[:existing_custom_field]
    @asset = Asset.new(existing_asset.attributes.except("id"))
    @asset.asset_custom_fields << existing_asset.asset_custom_fields
    @asset.name = params[:name]
    @asset.save   
    redirect_to :action => "edit", :id => @asset
  end

  # Gets all the data needed to edit an Asset.
  #
  # @return [Asset].
  def edit
    @asset = Asset.find_by_id params[:id]
    @user = User.find_by_id session[:user_id]
    @custom_field = AssetCustomField.new
    @custom_field.type = "AssetCustomField"
    @available_custom_fields = Array.new
    @asset.custom_field_values.each do |v|
      if !@asset.asset_custom_fields.include? v.custom_field
        @available_custom_fields << v.custom_field
      end
    end
  end

  # Saves an Asset to the DB.
  #
  # @return Nothing.
  def update
    @asset = Asset.find params[:id]
    @asset.update_attributes params[:asset]
    flash[:notice] = 'Your changes have been saved.'
    redirect_to :action => "edit", :id => @asset

  end

  # Deletes an Asset from the DB.
  #
  # @return Nothing.
  def delete
    asset = Asset.find params[:id]
    asset.delete
    #render :partial => 'asset_types/assets_list', :layout => false, :locals => { :asset_types => AssetType.all, :user => User.current }
  end

  # Creates an Asset CustomField.
  #
  # @return Nothing.
  def create_custom_field
    asset = Asset.find_by_id params[:id]
    if params[:existing_custom_field] != nil
      params[:existing_custom_field].each do |f|
        custom_field = AssetCustomField.find_by_id f
        asset.asset_custom_fields << custom_field
      end
    else
      custom_field = AssetCustomField.create!(params[:asset_custom_field])
      asset.asset_custom_fields << custom_field
    end
    asset.save
    redirect_to :action => "edit", :id => asset
  end

  # Removes a CustomField from an Asset.
  #
  # @return Nothing.
  def remove_custom_field
    asset = Asset.find_by_id params[:id]
    custom_field = AssetCustomField.find_by_id params[:existing_custom_field]
    asset.asset_custom_fields.delete custom_field
    asset.save
    redirect_to :action => "edit", :id => asset
  end

  # Modifies the collection of attachments of an Asset.
  #
  # @return Nothing.
  def edit_attachments
    @asset = Asset.find_by_id params[:id]
    if request.post?
      attachment = Attachment.find_by_id params[:attachment][:id]
      attachment.description = params[:attachment][:description]
      attachment.save
      flash.now[:notice] = 'Your changes were saved.'
    end
  end

  # Removes an Attachment from an Asset.
  #
  # @return Nothing.
  def remove_attachment
    attachment = Attachment.find_by_id params[:attachment_id]
    attachment.destroy
    @asset = Asset.find_by_id params[:asset_id]
    flash[:notice] = "Attachment successfully destroyed."
    redirect_to :controller => 'assets', :action => 'edit_attachments', :id => @asset
  end

  # Changes the privacy settings of an Attachment.
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
    @asset = Asset.find_by_id params[:asset_id]
    flash[:notice] = "Privacy settings updated."
    redirect_to :controller => 'assets', :action => 'edit_attachments', :id => @asset
  end

  # Displays an Attachment from the DB.
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

  # Displays an attached asset image.
  #
  # @return a valid image bitstream.
  def show_image
    asset = Asset.find_by_id params[:id]
    if asset != nil
      has_image=false;
      asset.attachments.each do |a|
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

  # Adds a new Attachment to an Asset.
  #
  # @return Nothing.
  def add_attachment
    @asset = Asset.find_by_id params[:id]

    if request.post?
      attachments = @asset.attach_files(params[:attachments])
      redirect_to :controller => 'assets', :action => 'edit_attachments', :id => @asset
      return
    end
  end

  private
    # Detects the content_type of an attachment.
    #
    # @return A valid content_type header.
    def detect_content_type(attachment)
      content_type = attachment.content_type
      if content_type.blank?
        content_type = Redmine::MimeType.of(attachment.filename)
      end
      content_type.to_s
    end
    end
