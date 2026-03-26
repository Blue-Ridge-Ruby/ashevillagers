class CreateVillagers < ActiveRecord::Migration[8.1]
  def change
    create_table :villagers do |t|
      t.string :first_name
      t.string :last_name
      t.string :email, null: false
      t.string :tito_account_slug
      t.string :tito_event_slug
      t.string :tito_ticket_slug

      t.timestamps
    end

    add_index :villagers, :tito_ticket_slug, unique: true
    add_index :villagers, :email
  end
end
