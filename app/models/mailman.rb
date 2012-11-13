# @author Emmanuel Pastor/Nitish Upreti
class Mailman < ActionMailer::Base

  default :from => "Berkman Robot<robot@cyber.law.harvard.com>"
  # Sends an Email reminder to all the users who missed a pickup date
  #
  # @return Nothing.
  def check_out_reminder(reservation)
    recipient = reservation.user.mail
    subject   = "Checkout Reminder for '#{reservation.bookable.name}'."
    mail(:to => recipient, :subject => subject)
  end

  def check_out_recurring_reminder(reservation)
     recipient = reservation.user.mail
     subject   = "Checkout Recurring Reminder for '#{reservation.bookable.name}'."
     mail(:to => recipient, :subject => subject)
  end

  # Sends an Email reminder to all the users who missed a return date
  #
  # @return Nothing.
  def check_in_reminder(reservation)
    recipient = reservation.user.mail
    subject   = "Checkin Reminder for '#{reservation.bookable.name}'."
    mail(:to => recipient, :subject => subject)
  end

  def check_in_recurring_reminder(reservation)
    recipient = reservation.user.mail
    subject   = "Checkin Recurring Reminder for '#{reservation.bookable.name}'."
    mail(:to => recipient, :subject => subject)
  end

  def digest_reminder(checkin_reservation_list,checkin_recurring_reservation_list,checkout_reservation_list,checkout_recurring_reservation_list)
    
    @checkout_reservation_list = checkout_reservation_list

    @checkin_reservation_list = checkin_reservation_list

    @checkout_recurring_reservation_list = checkout_recurring_reservation_list

    @checkin_recurring_reservation_list = checkin_recurring_reservation_list

    admin_email = "admin_email"
    subject   = "Daily Diget for #{DateTime.now.to_date} by CheckOut-CheckIn Asset Tracker"
    mail(:to => admin_email, :subject => subject)
  end

end

