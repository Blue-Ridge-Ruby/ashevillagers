class CreateStewards < ActiveRecord::Migration[8.1]
  def change
    create_table :stewards do |t|
      t.string :email, null: false
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :mobile_phone
      t.string :password_digest, null: false

      t.timestamps
    end

    add_index :stewards, :email, unique: true
  end
end
