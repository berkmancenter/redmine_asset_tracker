class AddAssetTypeColumn < ActiveRecord::Migration
  def self.up
    add_column :asset_groups, :asset_type_id, :integer
  end

  def self.down
    remove_column :asset_groups, :asset_type_id
  end
end