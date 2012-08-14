require File.dirname(__FILE__) + '/../test_helper'

class ReservationTest < ActiveSupport::TestCase
  fixtures :reservations
  fixtures :users

  def test_reservation_with_no_data
    reservation = Reservation.new
    assert !reservation.save
  end

  def test_asset_type_with_all_data
    reservation = Reservation.new
    reservation.bookable_id = 1
    reservation.bookable_type = "Asset"
    reservation.user_id = 1
    reservation.check_out_date = DateTime.now
    reservation.check_in_date = DateTime.now + 30
    reservation.status = Reservation::STATUS_READY
    assert reservation.save
  end

  def test_asset_type_with_no_bookable_id
    reservation = Reservation.new
    reservation.bookable_type = "Asset"
    reservation.user_id = 1
    reservation.check_out_date = DateTime.now
    reservation.check_in_date = DateTime.now + 30
    reservation.status = Reservation::STATUS_READY
    assert !reservation.save
  end

  def test_asset_type_with_no_bookable_type
    reservation = Reservation.new
    reservation.bookable_id = 1
    reservation.user_id = 1
    reservation.check_out_date = DateTime.now
    reservation.check_in_date = DateTime.now + 30
    reservation.status = Reservation::STATUS_READY
    assert !reservation.save
  end

  def test_asset_type_with_no_user_id
    reservation = Reservation.new
    reservation.bookable_id = 1
    reservation.bookable_type = "Asset"
    reservation.check_out_date = DateTime.now
    reservation.check_in_date = DateTime.now + 30
    reservation.status = Reservation::STATUS_READY
    assert !reservation.save
  end

  def test_asset_type_with_no_check_out_date
    reservation = Reservation.new
    reservation.bookable_id = 1
    reservation.bookable_type = "Asset"
    reservation.user_id = 1
    reservation.check_in_date = DateTime.now + 30
    reservation.status = Reservation::STATUS_READY
    assert !reservation.save
  end

  def test_asset_type_with_no_check_in_date
    reservation = Reservation.new
    reservation.bookable_id = 1
    reservation.bookable_type = "Asset"
    reservation.user_id = 1
    reservation.check_out_date = DateTime.now
    reservation.status = Reservation::STATUS_READY
    assert !reservation.save
  end

  def test_asset_type_with_no_status
    reservation = Reservation.new
    reservation.bookable_id = 1
    reservation.bookable_type = "Asset"
    reservation.user_id = 1
    reservation.check_out_date = DateTime.now
    reservation.check_in_date = DateTime.now + 30
    assert !reservation.save
  end

    #Tests for the Reminder feature of Reservation model
  def test_checkout_reminders_list_length_for_day
    reservation_list = Reservation.send_day_check_out_reminders 
    assert_equal reservation_list.length,2
  end

  def test_checkin_reminders_list_length_for_day
    reservation_list = Reservation.send_day_check_in_reminders 
    assert_equal reservation_list.length,1
  end


  def test_recurring_checkout_reminders_list_length_for_day
    reservation_list = Reservation.recurring_checkout_reservation_list
    assert_equal reservation_list.length,2
  end


  def test_recurring_checkin_remninders_list_length_for_day
    reservation_list = Reservation.recurring_checkin_reservation_list
    assert_equal reservation_list.length,2
  end 

  def test_digest
    Reservation.send_day_digest
  end


end
