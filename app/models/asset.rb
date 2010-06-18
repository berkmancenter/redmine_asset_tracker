class Asset < ActiveRecord::Base
  acts_as_customizable
  belongs_to :asset_type
  has_and_belongs_to_many :asset_custom_fields,
                          :class_name => 'AssetCustomField',
                          :order => "#{CustomField.table_name}.position",
                          :join_table => "#{table_name_prefix}custom_fields_assets#{table_name_suffix}",
                          :association_foreign_key => 'custom_field_id'
end
