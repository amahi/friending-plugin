
class CreateFriendRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :friend_requests do |t|
      t.integer :amahi_user_id, index: true
      t.integer :system_id, index: true
      t.integer :status, default: 1
      t.string :pin
      t.string :invite_token
      t.datetime :last_requested_at
      t.string :status_txt
      t.string :email

      t.timestamps
    end
  end
end
