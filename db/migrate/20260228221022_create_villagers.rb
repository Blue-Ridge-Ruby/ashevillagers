class CreateVillagers < ActiveRecord::Migration[8.1]
  def change
    create_table :villagers do |t|
      t.string :first_name
      t.string :last_name
      t.string :email, null: false
      t.string :tito_admin_url
      t.string :tito_ticket_id
      t.string :tito_ticket_slug

      t.timestamps
    end

    add_index :villagers, :email, unique: true
  end
end
