class Mailman < ActionMailer::Base

  def check_out_reminder(reservation)
    recipients reservation.user.mail
    from       "Berkman Robot<robot@cyber.law.harvard.com>"
    subject    "Checkout Reminder for '#{reservation.bookable.name}'."
    sent_on    Time.now
    content_type "text/plain"
    body       :reservation => reservation
  end

  def check_in_reminder(reservation)
    recipients reservation.user.mail
    from       "Berkman Robot<robot@cyber.law.harvard.com>"
    subject    "Checkin Reminder for '#{reservation.asset.name}'."
    sent_on    Time.now
    content_type "text/plain"
    body       :reservation => reservation
  end
  
end

