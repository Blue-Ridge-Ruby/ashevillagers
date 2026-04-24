class AddSelectedImageGenerationToProfiles < ActiveRecord::Migration[8.1]
  def change
    add_reference :profiles, :selected_image_generation,
      foreign_key: {to_table: :image_generations},
      null: true, index: true
  end
end
