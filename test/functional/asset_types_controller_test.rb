require File.dirname(__FILE__) + '/../test_helper'

class AssetTypesControllerTest < ActionController::TestCase

	test "should List all Asset Types" do
		get :index
		assert_response :success
		assert_not_nil assigns(:asset_types)
	end

end
