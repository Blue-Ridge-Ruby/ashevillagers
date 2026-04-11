class CreateProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :profiles do |t|
      t.references :villager, null: false, foreign_key: true, index: {unique: true}
      t.text :answer_1
      t.text :answer_2
      t.text :answer_3
      t.text :answer_4
      t.string :twitter_url
      t.string :bluesky_url
      t.string :mastodon_url
      t.string :linkedin_url
      t.string :website_url

      t.timestamps
    end
  end
end
