class AddHueToImageGenerations < ActiveRecord::Migration[8.1]
  def change
    add_column :image_generations, :hue, :string
  end
end
