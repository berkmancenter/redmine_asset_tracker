class AddAttachmentPrivacyLevelColumn < ActiveRecord::Migration
  def self.up
    add_column :attachments, :is_private, :boolean, {:default => false}
  end

  def self.down
    remove_column :attachments, :is_private
  end
end