# @author Emmanuel Pastor/Nitish Upreti
class Reservation < ActiveRecord::Base
  belongs_to :bookable, :polymorphic => true
  belongs_to :user
  STATUS_READY                = 'Ready'
  STATUS_CHECKED_OUT          = 'Checked Out'
  STATUS_CHECKED_IN           = 'Checked In'
  STATUS_MISSING_PICKUP_DATE  = 'Missing Pick-up date'
  STATUS_MISSING_RETURN_DATE  = 'Missing Return date'


  validates_presence_of :bookable_id, :bookable_type, :user_id, :check_out_date, :check_in_date, :status

  def self.recurring_checkout_reservation_list

    checkout_recurring_reservations_list = Array.new

    #For all recurring reservations uptill today
    filtered_reservations = Reservation.find :all, :conditions => ["status != ? AND status != ? AND check_out_date < ? AND is_recurring = ?",STATUS_CHECKED_OUT, STATUS_CHECKED_IN, DateTime.now+1, true] 

    filtered_reservations.each do |r|

      0.upto(r.repeat_count-1) do |rc|
        #One of the recurring step is the current date
        if (r.check_out_date + rc * IceCube::ONE_WEEK).to_date == DateTime.now.to_date then
          checkout_recurring_reservations_list.push(r)
          break #once a date is found equal to current date, no future dates can match current date
        end
      end

    end

   return checkout_recurring_reservations_list 
  end

  def self.recurring_checkin_reservation_list

    checkin_recurring_reservations_list = Array.new

    #For all recurring reservations checkins uptill today
    filtered_reservations = Reservation.find :all, :conditions => ["status = ? AND check_in_date <= ? AND is_recurring = ?", STATUS_CHECKED_OUT, DateTime.now+1, true] 

    filtered_reservations.each do |r|
      0.upto(r.repeat_count-1) do |rc|
        #One of the recurring step is the current date
        if (r.check_in_date + rc * IceCube::ONE_WEEK).to_date == DateTime.now.to_date then
          checkin_recurring_reservations_list.push(r)
          break #once a date is found equal to current date, no future dates can match current date
        end
      end
    end

    return checkin_recurring_reservations_list

  end

  # Sends an Email reminder to all the users who missed a pickup or a return date
  #
  # @return Nothing.
  def self.send_day_reminders
    send_day_check_out_reminder
    send_day_check_in_reminder
    send_day_digest
  end

  # Sends an Email reminder to all the users who missed a pickup date
  #
  # @return Nothing.
  def self.send_day_check_out_reminders
    checkout_reservations = Reservation.find :all, :conditions => ["status <> ? AND status <> ? AND check_out_date >= ? AND check_out_date < ? AND is_recurring = ?", STATUS_CHECKED_OUT, STATUS_CHECKED_IN , DateTime.now, DateTime.now + 1 ,false]
    checkout_recurring_reservations = recurring_checkout_reservation_list
    
    checkout_reservations.each do |r|
      Mailman.check_out_reminder r
    end

    checkout_recurring_reservations.each do |r|
      Mailman.check_out_recurring_reminder r
    end

    checkout_reservations #For tests sake
  end

  # Sends an Email reminder to all the users who missed a return date
  #
  # @return Nothing.
  def self.send_day_check_in_reminders
    checkin_reservations = Reservation.find :all, :conditions => ["status = ? AND check_in_date >= ? AND check_in_date < ? AND is_recurring = ?", STATUS_CHECKED_OUT, DateTime.now, DateTime.now+1, false]

    checkin_recurring_reservations = recurring_checkin_reservation_list

    checkin_reservations.each do |r|
      Mailman.check_in_reminder r
    end

    checkin_recurring_reservations.each do |r|
      Mailman.check_in_recurring_reminder r
    end

    checkin_reservations #For tests sake
  end

  def self.send_day_digest
    checkout_reservation_list = Reservation.find :all, :conditions => ["status <> ? AND status <> ? AND check_out_date >= ? AND check_out_date < ? AND is_recurring = ?", STATUS_CHECKED_OUT, STATUS_CHECKED_IN , DateTime.now, DateTime.now + 1 ,false]
   
    checkin_reservation_list = Reservation.find :all, :conditions => ["status = ? AND check_in_date >= ? AND check_in_date < ? AND is_recurring = ?", STATUS_CHECKED_OUT, DateTime.now, DateTime.now+1, false]

    checkin_recurring_reservation_list = recurring_checkin_reservation_list

    checkout_recurring_reservation_list = recurring_checkout_reservation_list

    Mailman.digest_reminder(checkin_reservation_list,checkin_recurring_reservation_list,checkout_reservation_list,checkout_recurring_reservation_list)

  end

end
