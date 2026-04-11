class AddNameFieldsToProfiles < ActiveRecord::Migration[8.1]
  def change
    add_column :profiles, :first_name, :string
    add_column :profiles, :last_name, :string
  end
end
