class CreateAssets < ActiveRecord::Migration
  def self.up
    create_table :assets do |t|

      t.column :name, :string
      t.column :description, :text
      t.references :asset_type

    end
  end

  def self.down
    drop_table :assets
  end
end
