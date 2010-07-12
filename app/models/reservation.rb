class Reservation < ActiveRecord::Base
  belongs_to :asset
  belongs_to :asset_group
  belongs_to :user
end
