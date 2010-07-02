class CreateAssetGroups < ActiveRecord::Migration
  def self.up
    create_table :asset_groups do |t|
      t.string :name
      t.text :description
    end
  end

  def self.down
    drop_table :asset_groups
  end
end