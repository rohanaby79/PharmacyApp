class AddActiveToDoctors < ActiveRecord::Migration[8.1]
  def change
    # Guard: only add if the column does not already exist (it was already added in create_doctors)
    unless column_exists?(:doctors, :active)
      add_column :doctors, :active, :boolean
    end
  end
end
