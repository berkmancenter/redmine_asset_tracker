class CreateFavourites < ActiveRecord::Migration
  def self.up
    create_table :favourites do |t|
    	t.references :user
    	t.string	 :item_type
    	t.integer	 :item_id
    end
  end

  def self.down
    drop_table :favourites
  end

end
