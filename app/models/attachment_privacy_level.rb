class AttachmentPrivacyLevel < ActiveRecord::Base
  validates_inclusion_of :privacy_level, :in => %w(admin_only admin_and_current_assignee public)
  belongs_to :attachment
end
