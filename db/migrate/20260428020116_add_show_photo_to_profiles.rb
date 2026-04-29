class AddShowPhotoToProfiles < ActiveRecord::Migration[8.1]
  def change
    add_column :profiles, :show_photo, :boolean, default: true, null: false
  end
end
