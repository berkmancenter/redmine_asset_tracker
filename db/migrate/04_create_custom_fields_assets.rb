class CreateCustomFieldsAssets < ActiveRecord::Migration
  def self.up
    create_table :custom_fields_assets, :id => false do |t|
      t.references :custom_field
      t.references :asset
    end
  end

  def self.down
    drop_table :custom_fields_assets
  end
end