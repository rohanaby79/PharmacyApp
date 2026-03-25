class CreatePrescriptions < ActiveRecord::Migration[8.1]
  def change
    create_table :prescriptions do |t|
      t.string :medication
      t.string :dosage
      t.string :frequency
      t.integer :quantity
      t.string :patient_id
      t.string :provider_id
      t.string :pharmacy_id
      t.string :status
      t.string :dea_schedule
      t.string :error_message
      t.datetime :transmitted_at

      t.timestamps
    end
  end
end
