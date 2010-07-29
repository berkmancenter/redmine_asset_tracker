# @author Emmanuel Pastor
class AssetCustomField < CustomField
  has_and_belongs_to_many :assets, :join_table => "#{table_name_prefix}custom_fields_assets#{table_name_suffix}", :foreign_key => "custom_field_id"
  #has_many :issues, :through => :issue_custom_values
  def type_name
    :label_asset_plural
  end
end