class CreatePrescriptionConfirmations < ActiveRecord::Migration[8.1]
  def change
    create_table :prescription_confirmations do |t|
      t.integer :prescription_id, null: false
      t.string :pharmacy_id
      t.string :status, null: false
      t.text :message
      t.datetime :confirmed_at, null: false

      t.timestamps
    end

    add_index :prescription_confirmations, :prescription_id
  end
end
