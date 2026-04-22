class CreateDeviceSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :device_sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :device_fingerprint, null: false
      t.string :device_name
      t.string :ip_address
      t.datetime :last_active_at
      t.string :session_token, null: false

      t.timestamps
    end

    add_index :device_sessions, :session_token, unique: true
    add_index :device_sessions, [:user_id, :device_fingerprint], unique: true
  end
end
