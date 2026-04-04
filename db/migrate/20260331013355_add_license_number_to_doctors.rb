class AddLicenseNumberToDoctors < ActiveRecord::Migration[8.1]
  def change
    # Guard: only add if the column does not already exist (it was already added in create_doctors)
    unless column_exists?(:doctors, :license_number)
      add_column :doctors, :license_number, :string
    end
  end
end
