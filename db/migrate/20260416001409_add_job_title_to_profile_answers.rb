class AddJobTitleToProfileAnswers < ActiveRecord::Migration[8.1]
  def change
    add_column :profile_answers, :job_title, :string
  end
end
