class CreatePrescriptionConfirmations < ActiveRecord::Migration[8.1]
  def change
    create_table :prescription_confirmations do |t|
      t.integer  :prescription_id, null: false
      t.string   :pharmacy_id,     null: false
      t.string   :status,          null: false   # received | ready_for_pickup | issue
      t.text     :message
      t.datetime :confirmed_at

      t.timestamps
    end

    add_index :prescription_confirmations, :prescription_id
  end
end
