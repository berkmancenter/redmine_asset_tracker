require File.expand_path('../../test_helper', __FILE__)

class MailmanTest < ActionMailer::TestCase
  fixtures :reservations
  fixtures :users

  def test_check_out_reminder
    reservation = Reservation.first 
    # Send the email, then test that it got queued
    email = Mailman.check_out_reminder(reservation).deliver
    assert !ActionMailer::Base.deliveries.empty?
 
    # Test the sent email contains what we expect it to
    assert_equal "Checkout Reminder for '#{reservation.bookable.name}'.", email.subject
  end


  def test_check_in_reminder
    reservation = Reservation.first 
    # Send the email, then test that it got queued
    email = Mailman.check_in_reminder(reservation).deliver
    assert !ActionMailer::Base.deliveries.empty?
 
    # Test the sent email contains what we expect it to
    assert_equal "Checkin Reminder for '#{reservation.bookable.name}'.", email.subject
  end


  

end