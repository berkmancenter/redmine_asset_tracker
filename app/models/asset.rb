 # @author Emmanuel Pastor/Nitish Upreti
class Asset < ActiveRecord::Base
  belongs_to :asset_type
  belongs_to :asset_group
  has_and_belongs_to_many :asset_custom_fields,
                          :class_name => 'AssetCustomField',
                          :order => "#{CustomField.table_name}.position",
                          :join_table => "#{table_name_prefix}custom_fields_assets#{table_name_suffix}",
                          :association_foreign_key => 'custom_field_id'
  has_many :reservations, :as => :bookable , :dependent => :destroy
  acts_as_customizable
  acts_as_attachable :view_permission => :view_files,
                     :delete_permission => :manage_files

  validates_presence_of :name
  validates_numericality_of :asset_type_id
  validates_length_of :name, :maximum=>30
  validates_format_of :name, :with => /^[\w\s\.\'\-]*$/i

  before_destroy :remove_as_favorite

  #When an asset is deleted we need to make sure all enteries in db marking it as fav are cleared as well
  def remove_as_favorite
    fav=Favourite.where(:item_id => self.id, :item_type => 'Asset')   

    fav.each do |f|
      f.destroy
    end
  end


  # Attaches a File to an Asset.
  #
  # @return Nothing.
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
