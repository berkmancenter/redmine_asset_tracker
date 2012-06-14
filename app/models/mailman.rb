# @author Emmanuel Pastor/Nitish Upreti
class Mailman < ActionMailer::Base

  # Sends an Email reminder to all the users who missed a pickup date
  #
  # @return Nothing.
  def check_out_reminder(reservation)
    recipients reservation.user.mail
    from       "Berkman Robot<robot@cyber.law.harvard.com>"
    subject    "Checkout Reminder for '#{reservation.bookable.name}'."
    sent_on    Time.now
    content_type "text/plain"
    body       :reservation => reservation
  end

  # Sends an Email reminder to all the users who missed a return date
  #
  # @return Nothing.
  def check_in_reminder(reservation)
    recipients reservation.user.mail
    from       "Berkman Robot<robot@cyber.law.harvard.com>"
    subject    "Checkin Reminder for '#{reservation.asset.name}'."
    sent_on    Time.now
    content_type "text/plain"
    body       :reservation => reservation
  end
  
end

