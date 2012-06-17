class Favourite < ActiveRecord::Base
  unloadable

  belongs_to :user
end
