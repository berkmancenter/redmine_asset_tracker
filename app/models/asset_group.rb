class AssetGroup < ActiveRecord::Base
  belongs_to :asset_type
  has_many :assets
end
