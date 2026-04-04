class CreatePrescriptionExports < ActiveRecord::Migration[8.1]
  def change
    create_table :prescription_exports do |t|
      t.integer  :prescription_id, null: false
      t.integer  :doctor_id,       null: false
      t.string   :file_path,       null: false
      t.string   :file_format,     null: false   # json | csv
      t.datetime :exported_at

      t.timestamps
    end

    add_index :prescription_exports, :prescription_id
    add_index :prescription_exports, :doctor_id
  end
end
