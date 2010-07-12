class Asset < ActiveRecord::Base
  belongs_to :asset_type
  belongs_to :asset_group
  has_and_belongs_to_many :asset_custom_fields,
                          :class_name => 'AssetCustomField',
                          :order => "#{CustomField.table_name}.position",
                          :join_table => "#{table_name_prefix}custom_fields_assets#{table_name_suffix}",
                          :association_foreign_key => 'custom_field_id'
  has_many :reservations
  acts_as_customizable
  acts_as_attachable :view_permission => :view_files,
                     :delete_permission => :manage_files

  def attach_files(attachments)
    attached = []
    unsaved = []
    if attachments && attachments.is_a?(Hash)
      attachments.each_value do |attachment|
        file = attachment['file']
        next unless file && file.size > 0
        a = Attachment.create(:container => self,
                              :file => file,
                              :description => attachment['description'].to_s.strip,
                              :author => User.current,
                              :is_private => attachment['is_private'])

        a.new_record? ? (unsaved << a) : (attached << a)
      end
      if unsaved.any?
        flash[:warning] = l(:warning_attachments_not_saved, unsaved.size)
      end
    end
    attached
  end


end
