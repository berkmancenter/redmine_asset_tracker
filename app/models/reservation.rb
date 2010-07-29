# @author Emmanuel Pastor
class Reservation < ActiveRecord::Base
  belongs_to :bookable, :polymorphic => true
  belongs_to :user
  STATUS_READY                = 'Ready'
  STATUS_CHECKED_OUT          = 'Checked Out'
  STATUS_CHECKED_IN           = 'Checked In'
  STATUS_MISSING_PICKUP_DATE  = 'Missing Pick-up date'
  STATUS_MISSING_RETURN_DATE  = 'Missing Return date'


  # Sends an Email reminder to all the users who missed a pickup or a return date
  #
  # @return Nothing.
  def self.send_reminders
    send_check_out_reminder
    send_check_in_reminder
  end

  # Sends an Email reminder to all the users who missed a pickup date
  #
  # @return Nothing.
  def self.send_check_out_reminder
    missed_reservations = Reservation.find :all, :conditions => ["status <> ? AND status <> ? AND check_out_date > ?", STATUS_CHECKED_OUT, STATUS_CHECKED_IN, DateTime.now]
    missed_reservations.each do |r|
      Mailman.deliver_check_out_reminder r
    end
  end

  # Sends an Email reminder to all the users who missed a return date
  #
  # @return Nothing.
  def self.send_check_in_reminder
    missed_reservations = Reservation.find :all, :conditions => ["status = ? AND check_in_date > ?", STATUS_CHECKED_OUT, DateTime.now]
    missed_reservations.each do |r|
      Mailman.deliver_check_in_reminder r
    end 
  end

end
