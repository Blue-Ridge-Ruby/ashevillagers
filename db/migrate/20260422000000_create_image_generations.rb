class CreateImageGenerations < ActiveRecord::Migration[8.1]
  def change
    create_table :image_generations do |t|
      t.references :profile_answer, null: false, foreign_key: true, index: {unique: true}
      t.string :animal
      t.boolean :cursed, default: false, null: false
      t.text :prompt

      t.timestamps
    end
  end
end
