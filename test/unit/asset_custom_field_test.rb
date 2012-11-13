require File.dirname(__FILE__) + '/../test_helper'

class AssetTest < ActiveSupport::TestCase
  #fixtures :asset_custom_fields

  def test_asset_custom_field_with_no_name
    asset_custom_field = AssetCustomField.new
    asset_custom_field.field_format = 'string'
    assert !asset_custom_field.save
  end

  def test_asset_custom_field_with_no_field_format
    asset_custom_field = AssetCustomField.new
    asset_custom_field.name = 'foo'
    assert !asset_custom_field.save
  end

  def test_asset_custom_field_with_wrong_field_format
    asset_custom_field = AssetCustomField.new
    asset_custom_field.name = 'foo'
    asset_custom_field.field_format = 'bar'
    assert !asset_custom_field.save
  end

  def test_repeated_asset_custom_field_name
    asset_custom_field = AssetCustomField.new
    asset_custom_field.name = 'foo'
    asset_custom_field.field_format = 'string'
    assert asset_custom_field.save
    repeated_asset_custom_field = AssetCustomField.new
    repeated_asset_custom_field.name = 'foo'
    repeated_asset_custom_field.field_format = 'string'
    assert !repeated_asset_custom_field.save
  end
end
