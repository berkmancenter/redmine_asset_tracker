require File.dirname(__FILE__) + '/../test_helper'

class AssetTest < ActiveSupport::TestCase
  #fixtures :asset_custom_fields

  def test_asset_group_with_no_name
    asset_group = AssetGroup.new
    asset_group.asset_type_id = 1
    assert !asset_group.save
  end

  def test_asset_group_with_no_asset_type
    asset_group = AssetGroup.new
    asset_group.name = 'foo'
    assert !asset_group.save
  end

  def test_asset_group_with_wrong_asset_type
    asset_group = AssetGroup.new
    asset_group.name = 'foo'
    asset_group.asset_type_id = 'bar'
    assert !asset_group.save
  end

  def test_asset_group_with_long_name
    asset_group = AssetGroup.new
    asset_group.name = 50.times.to_s
    asset_group.asset_type_id = 1
    assert !asset_group.save
  end

  def test_asset_group_with_funny_name
    asset_group = AssetGroup.new
    asset_group.name = '!?=123abc&%$'
    asset_group.asset_type_id = 1
    assert !asset_group.save
  end

  def test_repeated_asset_group_name
    asset_group = AssetGroup.new
    asset_group.name = 'foobar'
    asset_group.asset_type_id = 1
    assert asset_group.save
    repeated_asset_group = AssetGroup.new
    repeated_asset_group.name = 'foobar'
    repeated_asset_group.asset_type_id = 1
    assert !repeated_asset_group.save
  end
end
