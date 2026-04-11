class CreateProfileQuestions < ActiveRecord::Migration[8.1]
  def change
    create_table :profile_questions do |t|
      t.text :question, null: false
      t.text :llm_prompt
      t.boolean :active, null: false, default: true
      t.integer :position, null: false, default: 0

      t.timestamps
    end
  end
end
