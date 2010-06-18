class CreateAssetTypes < ActiveRecord::Migration
  def self.up
    create_table :asset_types do |t|
      t.column :name, :string
      t.column :description, :text
    end
  end

  def self.down
    drop_table :asset_types
  end
end