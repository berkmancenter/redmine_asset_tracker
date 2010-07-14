class CreateReservations < ActiveRecord::Migration
  def self.up
    create_table :reservations do |t|
      t.references  :bookable
      t.string      :bookable_type
      t.references  :user
      t.datetime    :check_out_date
      t.datetime    :check_in_date
      t.text        :notes
      t.string      :status
    end
  end

  def self.down
    drop_table :reservations
  end
end