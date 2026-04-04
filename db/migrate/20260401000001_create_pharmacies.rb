class CreatePharmacies < ActiveRecord::Migration[8.1]
  def change
    create_table :pharmacies do |t|
      t.string  :name,          null: false
      t.string  :identifier,    null: false
      t.string  :address,       null: false
      t.string  :zip,           null: false
      t.string  :phone_number
      t.boolean :supports_e_rx, null: false, default: true
      t.string  :pharmacy_type, null: false, default: "retail"   # 'retail' | 'mail_order'
      t.decimal :latitude,  precision: 10, scale: 7
      t.decimal :longitude, precision: 10, scale: 7

      t.timestamps
    end

    add_index :pharmacies, :identifier, unique: true
    add_index :pharmacies, :zip
  end
end
