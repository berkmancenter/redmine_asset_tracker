class AddAssetGroupColumn < ActiveRecord::Migration
  def self.up
    add_column :assets, :asset_group_id, :integer
  end

  def self.down
    remove_column :assets, :asset_group_id
  end
end