class CreatePrescriptionInstructions < ActiveRecord::Migration[8.1]
  def change
    create_table :prescription_instructions do |t|
      t.integer :prescription_id, null: false
      t.string  :medication
      t.string  :dosage
      t.string  :frequency
      t.string  :duration
      t.text    :notes
      t.integer :doctor_id
      t.string  :patient_id
      t.string  :pharmacy_id
      t.string  :provider_id
      t.string  :quantity
      t.timestamps
    end
    add_index :prescription_instructions, :prescription_id
    add_index :prescription_instructions, :doctor_id
  end
end
