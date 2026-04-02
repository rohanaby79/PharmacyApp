class CreateTransmissionLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :transmission_logs do |t|
      t.integer :doctor_id
      t.integer :pharmacy_id
      t.integer :prescription_id
      t.string :action
      t.string :status
      t.string :ip_address

      t.timestamps
    end
  end
end
