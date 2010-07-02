class AssetType < ActiveRecord::Base
  has_many :assets
  has_many :asset_groups
end
