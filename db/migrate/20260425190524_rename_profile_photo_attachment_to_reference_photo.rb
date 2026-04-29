class RenameProfilePhotoAttachmentToReferencePhoto < ActiveRecord::Migration[8.1]
  def up
    ActiveStorage::Attachment.where(record_type: "Profile", name: "photo").update_all(name: "reference_photo")
  end

  def down
    ActiveStorage::Attachment.where(record_type: "Profile", name: "reference_photo").update_all(name: "photo")
  end
end
