class CreateProfileAnswers < ActiveRecord::Migration[8.1]
  def change
    create_table :profile_answers do |t|
      t.references :profile, null: false, foreign_key: true
      t.references :profile_question, null: false, foreign_key: true
      t.text :answer

      t.timestamps

      t.index %i[profile_id profile_question_id], unique: true
    end
  end
end
