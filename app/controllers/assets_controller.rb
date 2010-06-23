class AssetsController < ApplicationController
  unloadable
  helper :custom_fields
  include CustomFieldsHelper
  before_filter :require_admin, :except => [:index, :show]

  def index
    @assets = Asset.find:all
  end

  def show
    @asset = Asset.find_by_id params[:id]
  end


  def new
    @asset = Asset.new
  end

  def create
    @asset = Asset.create params[:asset]
    redirect_to :action => "edit", :id => @asset
  end

  def clone
    existing_asset = Asset.find_by_id params[:existing_custom_field]
    @asset = Asset.new(existing_asset.attributes.except("id"))
    @asset.asset_custom_fields << existing_asset.asset_custom_fields
    @asset.name = params[:name]
    @asset.save   
    redirect_to :action => "edit", :id => @asset
  end

  def edit
    @asset = Asset.find_by_id params[:id]
    @custom_field = AssetCustomField.new
    @custom_field.type = "AssetCustomField"
    @available_custom_fields = Array.new
    @asset.custom_field_values.each do |v|
      if !@asset.asset_custom_fields.include? v.custom_field
        @available_custom_fields << v.custom_field
      end
    end
  end

  def update
    @asset = Asset.find params[:id]
    @asset.update_attributes params[:asset]
    redirect_to :action => "edit", :id => @asset
  end

  def delete
    asset = Asset.find params[:id]
    asset.delete
    redirect_to :controller => 'asset_types', :action => 'index'
  end

  def create_custom_field
    asset = Asset.find_by_id params[:id]
    if params[:existing_custom_field] != nil
      params[:existing_custom_field].each do |f|
        custom_field = AssetCustomField.find_by_id f
        asset.asset_custom_fields << custom_field
      end
    else
      custom_field = AssetCustomField.create!(params[:custom_field])
      asset.asset_custom_fields << custom_field
    end
    asset.save
    redirect_to :action => "edit", :id => asset
  end

  def remove_custom_field
    asset = Asset.find_by_id params[:id]
    custom_field = AssetCustomField.find_by_id params[:existing_custom_field]
    asset.asset_custom_fields.delete custom_field
    asset.save
    redirect_to :action => "edit", :id => asset
  end

  def add_file
    @asset = Asset.find_by_id params[:id]

    if request.post?
      if @asset.attachments.count > 0
        @asset.attachments[0].destroy
      end
      container = @asset
      attach_files(container, params[:attachments])
      redirect_to :controller => 'assets', :action => 'edit', :id => @asset
      return
    end
  end

  def show_file
    @asset = Asset.find_by_id params[:id]
    @attachment =@asset.attachments[0]
    send_file @attachment.diskfile, :filename => filename_for_content_disposition(@attachment.filename),
                                    :type => detect_content_type(@attachment),
                                    :disposition => (@attachment.image? ? 'inline' : 'attachment')
  end

  private
    def detect_content_type(attachment)
      content_type = attachment.content_type
      if content_type.blank?
        content_type = Redmine::MimeType.of(attachment.filename)
      end
      content_type.to_s
    end

end
