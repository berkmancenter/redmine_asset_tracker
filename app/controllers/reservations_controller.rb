# @author Emmanuel Pastor/Nitish Upreti
class ReservationsController < PluginController
  unloadable
  include IceCube
  before_filter :require_login, :only => [:new,:create]
  before_filter :require_admin, :only => [:delete,:change_status]

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

    is_recurring=params[:is_recurring]
    repeat_count=params[:repeat_count]

    if is_recurring == nil then 
      
      if params[:checkin] == nil || params[:checkout] == nil
        @error_message = "Dates can't be empty"
        return
      end

      in_date = Time.zone.parse(params[:checkin]).to_datetime
      out_date = Time.zone.parse(params[:checkout]).to_datetime

      logger.info(in_date)
      logger.info(out_date)

      #Make sure that check-in happens after check-out
      if out_date > in_date
        @error_message = "Checkout date can't happen after Checkin"
        return
      end

      #Make sure both are in the future
      if in_date < Time.now || out_date < Time.now
        @error_message = "Dates can't be in the past"
        return
      end

      #check collision with non-recurring reservations
      reservations = Reservation.where("bookable_id = :bookable_id AND bookable_type = :bookable_type AND status <> :status AND ((:out_date >= check_out_date AND  :out_date <= check_in_date) OR (:in_date <= check_in_date AND :in_date >= check_out_date) OR (:out_date <= check_in_date AND :in_date >= check_in_date)) AND is_recurring= :is_recurring", :bookable_id => params[:bookable_id], :bookable_type => params[:bookable_type], :status => Reservation::STATUS_CHECKED_IN, :out_date => out_date, :in_date => in_date, :is_recurring => false)
      
      if !reservations.empty?
        @error_message = "This Asset has already been reserved for those dates"
        return
      end

      #Check collisions with recurring reservations which were started prior to this reservation
      reservations = Reservation.find :all, :conditions => ["bookable_id = ? AND bookable_type = ? AND check_out_date <= ? AND status <> ? AND is_recurring = ?",params[:bookable_id],params[:bookable_type],in_date,Reservation::STATUS_CHECKED_IN,true]
      logger.info(reservations)

      current_schedule=Schedule.new(out_date, {:duration => in_date - out_date})
      #A serious bug in ice_cube forces us to add a recurrence rule if we want conflict_with to work, so adding one
      current_schedule.add_recurrence_rule Rule.yearly(5) #repear every 5 years which is pointless
      logger.info("Current:")
      logger.info(current_schedule)
      logger.info(current_schedule.end_time)
      logger.info(current_schedule.duration)


      reservations.each do |r|
        schedule=Schedule.new(r.check_out_date,{ :duration =>r.check_in_date - r.check_out_date, :end_time => r.check_in_date + r.repeat_count*IceCube::ONE_WEEK })
        schedule.add_recurrence_rule Rule.weekly

        logger.info("Db:")
        logger.info(schedule)
        logger.info(schedule.duration)
        logger.info(schedule.end_time)
        logger.info(schedule.conflicts_with?(current_schedule))
        logger.info(schedule.first(r.repeat_count))

        if schedule.conflicts_with?(current_schedule) then
          @error_message ="This Reservation conflicts with another recurring reservation,Contact the Administrator."
          return
        end
      end

      reservation = Reservation.new
      reservation.bookable_type = params[:bookable_type]
      reservation.bookable_id = params[:bookable_id]
      reservation.user = User.find_by_id params[:user_id]
      reservation.check_in_date = in_date
      reservation.check_out_date = out_date
      reservation.status = Reservation::STATUS_READY
      reservation.notes = params[:notes]
      reservation.is_recurring = false
      reservation.repeat_count = 0
      reservation.save
    else
      check_out_time = DateTime.strptime(params[:checkout], "%Y-%m-%d %H:%M" )

      if check_out_time < Time.now then
        @error_message = "Dates can't be in the past"
        return
      end

      if repeat_count > 52 then
        @error_message = "Cannot create a Recurring Reservation which spans for more than a year"
        return
      end

      if repeat_count <= 1 then
        @error_message = "Invalid Repeat Count Value"
        return
      end

      schedule = Schedule.new(check_out_time)
      schedule.add_recurrence_time(check_out_time)
      schedule.add_recurrence_rule(Rule.weekly)

      #Check for any possible collisions with existing non-recurring reservations
      # TO DO:
    end

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
    @reservations = @reservations.sort_by { |r| r.bookable.name }
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