class CreateAuthTokens < ActiveRecord::Migration[8.1]
  def change
    create_table :auth_tokens do |t|
      t.string :token
      t.integer :doctor_id
      t.datetime :expires_at

      t.timestamps
    end
  end
end
