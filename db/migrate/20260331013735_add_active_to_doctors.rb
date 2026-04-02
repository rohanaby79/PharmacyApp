class AddActiveToDoctors < ActiveRecord::Migration[8.1]
  def change
    add_column :doctors, :active, :boolean
  end
end
