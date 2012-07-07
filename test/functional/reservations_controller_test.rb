require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../app/controllers/reservations_controller'

class ReservationsControllerTest < ActionController::TestCase
      fixtures :reservations, :assets , :users

      def setup
            @controller = ReservationsController.new
            @request    = ActionController::TestRequest.new
            @response   = ActionController::TestResponse.new
            User.current = nil
            @request.session[:user_id] = 1 # admin
      end

	test "conflicting non-recurring reservation with another non-recurring reservation should give error" do
            checkout = (Time.now + 1.hour).to_s
            checkin  = (Time.now + 1.5.hour).to_s
		post :create, :bookable_type => "Asset", :bookable_id => "11", :checkout=> checkout, :checkin => checkin, :repeat_count=>"", :user_id=>"1", :notes=>"noo" 
		assert_equal(assigns(:error_message),"This Asset has already been reserved for those dates")
      end

      test "conflicting non-recurring reservaton with another recurring reservation should give error" do
            checkout = (Time.now + 14.days)
            checkin  = (Time.now + 16.days)
            post :create, :bookable_type => "Asset", :bookable_id => "11", :checkout=> checkout, :checkin => checkin, :repeat_count=>"", :user_id=>"1", :notes=>"noo" 
            assert_equal(assigns(:error_message),"This Reservation conflicts with another recurring reservation,Contact the Administrator")
      end

      test "recurring reservations cannot span more than 52 weeks(i.e 1 year)" do
            checkout = (Time.now + 1.days)
            checkin  = (Time.now + 2.days)
            post :create, :bookable_type => "Asset", :bookable_id => "11", :checkout=> checkout, :checkin => checkin, :repeat_count=>"", :user_id=>"1", :notes=>"noo", :is_recurring => "1", :repeat_count => "53" 
            assert_equal(assigns(:error_message),"Cannot create a Recurring Reservation which spans for more than a year")
      end

      test "conflicting recurring reservation with another non-recurring reservation should give error" do
            checkout = (Time.now + 1.days)
            checkin  = (Time.now + 2.days)
            post :create, :bookable_type => "Asset", :bookable_id => "11", :checkout=> checkout, :checkin => checkin, :is_recurring =>"1", :repeat_count=>"2", :user_id=>"1", :notes=>"noo" 
            assert_equal(assigns(:error_message),"This Recurring Reservation conflicts with another existing Non-Recurring Reservation")
      end

      test "conflicting recurring reservation with another recurring reservation should give error" do
            checkout = (Time.now + 14.days)
            checkin  = (Time.now + 16.days)
            post :create, :bookable_type => "Asset", :bookable_id => "11", :checkout=> checkout, :checkin => checkin, :is_recurring => "1", :repeat_count=>"3", :user_id=>"1", :notes=>"noo" 
            assert_equal(assigns(:error_message),"This Recurring Reservation conflicts with another recurring reservation,Contact the Administrator")
      end

end