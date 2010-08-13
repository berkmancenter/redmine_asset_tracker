require File.dirname(__FILE__) + '/../test_helper'

class AssetTest < ActiveSupport::TestCase
  #fixtures :asset_custom_fields

  def test_asset_type_with_no_name
    asset_type = AssetType.new
    assert !asset_type.save
  end

  def test_asset_type_with_all_data
    asset_type = AssetType.new
    asset_type.name = 'foo'
    asset_type.description = 'bar'
    assert asset_type.save
  end

  def test_asset_type_with_no_description
    asset_type = AssetType.new
    asset_type.name = 'foo'
    assert asset_type.save
  end

  def test_asset_type_with_long_name
    asset_type = AssetType.new
    asset_type.name = 50.times.to_s
    assert !asset_type.save
  end

  def test_asset_type_with_funny_name
    asset_type = AssetType.new
    asset_type.name = '!?=123abc&%$'
    assert !asset_type.save
  end

  def test_repeated_asset_type_name
    asset_type = AssetType.new
    asset_type.name = 'foobar'
    assert asset_type.save
    repeated_asset_type = AssetType.new
    repeated_asset_type.name = 'foobar'
    assert !repeated_asset_type.save
  end
end
