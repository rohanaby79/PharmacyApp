class ChangeTransmissionLogsPharmacyIdToString < ActiveRecord::Migration[8.1]
  def change
    change_column :transmission_logs, :pharmacy_id, :string
  end
end
