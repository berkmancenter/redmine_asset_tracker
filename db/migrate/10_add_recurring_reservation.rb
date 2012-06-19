class AddRecurringReservation < ActiveRecord::Migration
  def self.up
    add_column :reservations, :is_recurring, :boolean
    add_column :reservations, :repeat_count, :integer     
  end

  def self.down
    remove_column :reservations, :is_recurring
    remove_column :reservations, :repeat_count    
  end
end