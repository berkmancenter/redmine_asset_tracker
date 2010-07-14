class ReservationsController < ApplicationController
  unloadable
  #before_filter :require_admin, :except => [:index, :show, :show_attachment, :show_image]

  def index
    #@bookable = find_bookable
    #@reservations = @bookable.reservations
    @reservations = Reservation.all
    @reservations.each do |r|
      if Time.now > r.check_out_date
        r.status = Reservation::STATUS_MISSING_PICKUP_DATE
      end
      if Time.now > r.check_in_date
        r.status = Reservation::STATUS_MISSING_RETURN_DATE
      end
      r.save
    end
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
      reservation.bookable_type = 'asset'
    else
      reservation.bookable_type = 'asset_group'
    end

    reservation.bookable_id = params[:object_id]
    reservation.user = User.find_by_id params[:user_id]
    reservation.check_in_date = params[:checkin]
    reservation.check_out_date = params[:checkout]
    reservation.status = Reservation::STATUS_READY
    reservation.save
    respond_to do |format|
      format.html
      format.js
    end
  end

  def find_bookable
    params.each do |name, value|
      if name =~ /(.+)_id$/
        return $1.classify.constantize.find(value)
      end
    end
  end

end