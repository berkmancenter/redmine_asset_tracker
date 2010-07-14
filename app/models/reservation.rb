class Reservation < ActiveRecord::Base
  belongs_to :bookable, :polymorphic => true
  belongs_to :user
  STATUS_READY                = 'Ready'
  STATUS_CHECKED_OUT          = 'Checked Out'
  STATUS_CHECKED_IN           = 'Checked In'
  STATUS_MISSING_PICKUP_DATE  = 'Missing Pick-up date'
  STATUS_MISSING_RETURN_DATE  = 'Missing Return date'
end
