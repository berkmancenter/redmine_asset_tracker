class ReservationsController < ApplicationController
  unloadable
  #before_filter :require_admin, :except => [:index, :show, :show_attachment, :show_image]

  def index
    object_type = params[:object_type]
    if object_type == "asset"
      @reservations = Reservation.find_all_by_asset_id params[:object_id]
    else
      @reservations = Reservation.find_all_by_asset_group_id params[:object_id]
    end
    render 'index', :layout=>false
  end

  def new
    @reservation = Reservation.new
    @object_type = params[:object_type]
    if @object_type == "asset"
      @object = Asset.find_by_id params[:id]
    else
      @object = AssetGroup.find_by_id params[:id]
    end
    @users = User.find(:all)
    render 'new', :layout=>false
  end

  def create
    #TODO: Remove reserved_type column
    object_type = params[:object_type]
    reservation = Reservation.new
    if object_type == 'asset'
      object = Asset.find_by_id params[:object_id]
      reservation.asset = object
      #reservation.reserved_type = 'asset'
    else
      object = AssetGroup.find_by_id params[:object_id]
      reservation.asset_group = object
      #reservation.reserved_type = 'asset_group'
    end
    reservation.user = User.find_by_id params[:user_id]
    reservation.check_in_date = params[:checkin]
    reservation.check_out_date = params[:checkout]
    reservation.save
    respond_to do |format|
      format.html
      format.js
    end
  end

end