class RemoveAnswerColumnsFromProfiles < ActiveRecord::Migration[8.1]
  def change
    remove_column :profiles, :answer_1, :text
    remove_column :profiles, :answer_2, :text
    remove_column :profiles, :answer_3, :text
    remove_column :profiles, :answer_4, :text
  end
end
