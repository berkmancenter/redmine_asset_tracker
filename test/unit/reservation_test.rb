require File.dirname(__FILE__) + '/../test_helper'

class AssetTest < ActiveSupport::TestCase
  #fixtures :asset_custom_fields

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
end
