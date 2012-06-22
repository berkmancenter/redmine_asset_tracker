class Favourite < ActiveRecord::Base
  unloadable

  belongs_to :user
  validates_presence_of :user_id, :item_type , :item_id
end
