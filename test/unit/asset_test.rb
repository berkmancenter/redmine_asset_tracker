require File.dirname(__FILE__) + '/../test_helper'

class AssetTest < ActiveSupport::TestCase
  fixtures :assets

  def test_asset_with_no_name
    asset = Asset.new
    asset.description = 'foo'
    asset.asset_type_id = 1
    assert !asset.save
  end

  def test_asset_with_no_type
    asset = Asset.new
    asset.name = 'foo'
    asset.description = 'bar'
    assert !asset.save
  end

  def test_asset_with_no_description
    asset = Asset.new
    asset.name = 'foo'
    asset.asset_type_id = 1
    assert asset.save
  end

  def test_asset_with_long_name
    asset = Asset.new
    asset.name = 50.times.to_s
    asset.asset_type_id = 1
    assert !asset.save
  end

  def test_asset_with_funny_name
    asset = Asset.new
    asset.name = '!?=123abc&%$'
    asset.asset_type_id = 1
    assert !asset.save
  end
end
