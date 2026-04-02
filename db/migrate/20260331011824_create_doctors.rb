class CreateDoctors < ActiveRecord::Migration[8.1]
  def change
    create_table :doctors do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :license_number, null: false
      t.boolean :active, null: false, default: true
      t.string :password_digest, null: false

      t.timestamps
    end

    # Ensure emails and license numbers are unique
    add_index :doctors, :email, unique: true
    add_index :doctors, :license_number, unique: true
  end
end
