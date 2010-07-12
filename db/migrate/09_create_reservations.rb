class CreateReservations < ActiveRecord::Migration
  def self.up
    create_table :reservations do |t|
      t.references  :asset
      t.references  :asset_group
      t.references  :user
      t.datetime    :check_out_date
      t.datetime    :check_in_date
    end
  end

  def self.down
    drop_table :reservations
  end
end