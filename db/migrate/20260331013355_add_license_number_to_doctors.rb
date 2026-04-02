class AddLicenseNumberToDoctors < ActiveRecord::Migration[8.1]
  def change
    add_column :doctors, :license_number, :string
  end
end
