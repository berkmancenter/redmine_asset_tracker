# @author Emmanuel Pastor/Nitish Upreti
class AssetType < ActiveRecord::Base
  has_many :assets
  has_many :asset_groups
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_length_of :name, :maximum => 30
  validates_format_of :name, :with => /^[\w\s\.\'\-]*$/i
end