# @author Emmanuel Pastor
class ReservationsController < ApplicationController
  unloadable
  #before_filter :require_admin, :except => [:index, :show, :show_attachment, :show_image]

  # Lists all the Reservations from the DB.
  #
  # @return [Reservation] array.
  def index
    fifteen_days_ago = DateTime.now - 15
    next_fifteen_days = DateTime.now + 15
    @reservations = Reservation.find :all, :conditions => ["status <> '" + Reservation::STATUS_CHECKED_IN + "' AND (check_in_date BETWEEN ? AND ? OR check_out_date BETWEEN ? AND ?)", fifteen_days_ago, next_fifteen_days, fifteen_days_ago, next_fifteen_days]
    @reservations.each do |r|
      if (Time.now > r.check_out_date  && r.status != Reservation::STATUS_CHECKED_OUT)
        r.status = Reservation::STATUS_MISSING_PICKUP_DATE
      end
      if Time.now > r.check_in_date
        r.status = Reservation::STATUS_MISSING_RETURN_DATE
      end
      r.save
    end
    @reservations = @reservations.sort_by {|r| r.bookable.name }
  end

  # Creates a new Reservation instance, ready to be written to the DB.
  #
  # @return [Reservation].
  def new
    @reservation = Reservation.new
    @object_type = params[:object_type]
    if @object_type == "Asset"
      @object = Asset.find_by_id params[:id]
    else
      @object = AssetGroup.find_by_id params[:id]
    end
    @users = User.find(:all)
    render 'new', :layout=>false
  end


  # Creates a Reservation in the DB.
  #
  # @return Nothing.
  def create

    if params[:checkin] == nil || params[:checkout] == nil
      @error_message = "Dates can't be empty"
      return
    end

    in_date = DateTime.strptime params[:checkin], "%Y-%m-%d %H:%M"
    out_date = DateTime.strptime params[:checkout], "%Y-%m-%d %H:%M"

    #Make sure that check-in happens after check-out
    if out_date > in_date
      @error_message = "Checkout date can't happen after Checkin"
      return
    end

    #Make sure both are in the future
    if in_date < DateTime.now || out_date < DateTime.now
      @error_message = "Dates can't be in the past"
      return
    end

    #Finally check for possible collisions with existing reservations
    reservations = Reservation.find :all, :conditions => ["bookable_id = ? AND bookable_type = ? AND status <> ? AND ((? >= check_out_date AND ? <= check_in_date) OR (? <= check_in_date AND ? >= check_out_date))", params[:bookable_id], params[:bookable_type], Reservation::STATUS_CHECKED_IN, params[:checkout], params[:checkout], params[:checkin], params[:checkin]]
    if !reservations.empty?
      @error_message = "This Asset has already been reserved for those dates"
      return
    end

    reservation = Reservation.new
    reservation.bookable_type = params[:bookable_type]
    reservation.bookable_id = params[:bookable_id]
    reservation.user = User.find_by_id params[:user_id]
    reservation.check_in_date = params[:checkin]
    reservation.check_out_date = params[:checkout]
    reservation.status = Reservation::STATUS_READY
    reservation.notes = params[:notes]
    reservation.save
    respond_to do |format|
      format.html
      format.js
    end
  end

  # Search reservations by the polymorphic bookable class.
  #
  # @return [Reservation].
  def show_by_bookable
    @reservations = Reservation.find :all, :conditions => "bookable_id = '" + params[:bookable_id] + "' AND bookable_type = '" + params[:bookable_type] + "' AND status <> '" + Reservation::STATUS_CHECKED_IN + "'"
    @criteria = 'ASSET_NAME'
    @direction = 'DESC'
    render 'show_by_bookable', :layout => false
  end

  # Sorts a resultset of reservations.
  #
  # @return [Reservation] array.
  def sort
    resultset = params[:resultset]
    criteria = params[:criteria]
    direction = params[:direction]
    reservations = Reservation.find(resultset)
    if criteria == 'ASSET_NAME'
      reservations = reservations.sort_by {|r| r.bookable.name }
    elsif criteria == 'USER_NAME'
      reservations = reservations.sort_by {|r| r.user.firstname }
    elsif criteria == 'CHECK_OUT_DATE'
      reservations = reservations.sort_by {|r| r.check_out_date }
    elsif criteria == 'CHECK_IN_DATE'
      reservations = reservations.sort_by {|r| r.check_in_date }
    elsif criteria == 'STATUS'
      reservations = reservations.sort_by {|r| r.status }
    end

    if direction == 'ASC'
      reservations = reservations.reverse
    end
    render :partial => 'sorted_list_of_reservations', :layout => false, :locals => { :reservations => reservations, :criteria => criteria, :direction => direction }
    
  end

  # Changes the status of a reservation.
  #
  # @return Nothing.
  def change_status
    reservation = Reservation.find_by_id params[:id]
    reservation.status = params[:status]
    if reservation.status == Reservation::STATUS_CHECKED_IN
      reservation.check_in_date = DateTime.now
      params[:resultset] = params[:resultset].delete_if {|x| x == params[:id] }
    elsif reservation.status == Reservation::STATUS_CHECKED_OUT
      reservation.check_out_date = DateTime.now
    end
    reservation.save
    self.sort
  end

  # Deletes a Reservation from the DB.
  #
  # @return Nothing.
  def delete
    reservation = Reservation.find_by_id params[:id]
    reservation.delete
    params[:resultset] = params[:resultset].delete_if {|x| x == params[:id] }
    self.sort
  end

  # Searches reservations via ajax.
  #
  # @return [Reservation] array.
  def live_search

    if !request.env['HTTP_REFERER'].upcase.include? "history".upcase
      params[:resultset] = Reservation.find :all, :conditions => "status <> '" + Reservation::STATUS_CHECKED_IN + "'"
    else
      params[:resultset] = Reservation.find :all, :conditions => "status = '" + Reservation::STATUS_CHECKED_IN + "'"      
    end
    if !params[:asset_name].empty?
      params[:resultset] = params[:resultset].delete_if {|x| !x.bookable.name.upcase.include? params[:asset_name].upcase }
    end
    if params[:own] != nil
      params[:resultset] = params[:resultset].delete_if {|x| x.user.id != User.current.id }     
    else
      if !params[:user_firstname].empty?
        params[:resultset] = params[:resultset].delete_if {|x| !x.user.firstname.upcase.include? params[:user_firstname].upcase }
      end
      if !params[:user_lastname].empty?
        params[:resultset] = params[:resultset].delete_if {|x| !x.user.lastname.upcase.include? params[:user_lastname].upcase }
      end
    end
    if !params[:user_email].empty?
      params[:resultset] = params[:resultset].delete_if {|x| !x.user.mail.upcase.include? params[:user_email].upcase }
    end
    if !params[:days].empty?
      days_ago = (DateTime.now - params[:days].to_i)
      days_from_now = (DateTime.now + params[:days].to_i)
      params[:resultset] = params[:resultset].delete_if {|x| (x.check_out_date < days_ago || x.check_out_date > days_from_now) && (x.check_in_date < days_ago || x.check_in_date > days_from_now) }
    end
    params[:criteria] = "ASSET_NAME"
    params[:direction] = "DESC"
    self.sort
  end

  # Displays old reservations.
  #
  # @return [Reservation] array.
  def history
    #@bookable = find_bookable
    #@reservations = @bookable.reservations
    @reservations = Reservation.find :all, :conditions => "status = '" + Reservation::STATUS_CHECKED_IN + "'"
    @reservations = @reservations.sort_by {|r| r.bookable.name }
  end

  # Displays any notes added to a given reservation.
  #
  # @return [Reservation].
  def show_notes
    reservation = Reservation.find params[:id]
    render :partial => 'show_notes', :layout => false, :locals => { :reservation => reservation }
  end

  # Updates any notes added to a given Reservation.
  #
  # @return Nothing.
  def update_notes
    reservation = Reservation.find params[:id]
    reservation.notes = params[:notes]
    reservation.save
  end

  # Checks for all the requisites of a reservation before creating one in the DB.
  #
  # @return An error message if any of the requisites is not met, or nothing if all the requisites are fulfilled.
  def check_new_form

    if params[:checkin] == nil || params[:checkout] == nil
      @error_message = "Dates can't be empty"
      return
    end

    in_date = DateTime.strptime params[:checkin], "%Y-%m-%d %H:%M"
    out_date = DateTime.strptime params[:checkout], "%Y-%m-%d %H:%M"

    #Make sure that check-in happens after check-out
    if out_date > in_date
      @error_message = "Checkout date can't happen after Checkin"
      return
    end

    #Make sure both are in the future
    if in_date <= DateTime.now || out_date <= DateTime.now
      @error_message = "Dates can't be in the past"
      return
    end

    #Finally check for possible collisions with existing reservations
    #reservations = Reservation.find :all, :conditions => ["bookable_id = ? AND bookable_type = ? AND status <> ? AND ((check_out_date BETWEEN ? AND ? OR check_in_date BETWEEN ? AND ?) OR (? BETWEEN check))", params[:bookable_id], params[:bookable_type], Reservation::STATUS_CHECKED_IN, params[:checkout], params[:checkin], params[:checkout], params[:checkin]]
    reservations = Reservation.find :all, :conditions => ["bookable_id = ? AND bookable_type = ? AND status <> ? AND ((? >= check_out_date AND ? <= check_in_date) OR (? <= check_in_date AND ? >= check_out_date))", params[:bookable_id], params[:bookable_type], Reservation::STATUS_CHECKED_IN, params[:checkout], params[:checkout], params[:checkin], params[:checkin]]
    if !reservations.empty?
      @error_message = "This Asset has already been reserved for those dates"
      return
    end
  end

  # Finds out what type of class a bookable (polymorphic class) is
  #
  # @return A string representing the bookable type.
  def find_bookable
    params.each do |name, value|
      if name =~ /(.+)_id$/
        return $1.classify.constantize.find(value)
      end
    end
  end

end