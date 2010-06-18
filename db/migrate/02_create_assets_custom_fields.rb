class CreateAssetsCustomFields < ActiveRecord::Migration
  def self.up
    create_table :assets_custom_fields do |t|
      t.references :asset
      t.references :custom_field
    end
  end

  def self.down
    drop_table :assets_custom_fields
  end
end