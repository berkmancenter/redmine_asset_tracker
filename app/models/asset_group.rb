# @author Emmanuel Pastor/Nitish Upreti
class AssetGroup < ActiveRecord::Base
  belongs_to :asset_type
  has_many :assets
  has_many :reservations, :as => :bookable 
  acts_as_attachable :view_permission => :view_files,
                     :delete_permission => :manage_files

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_length_of :name, :maximum => 30
  validates_format_of :name, :with => /^[\w\s\.\'\-]*$/i
  validates_numericality_of :asset_type_id

  # Attaches a File to an AssetGroup.
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
        return false
      end
    end
    attached
  end
end
