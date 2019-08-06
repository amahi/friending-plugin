class CreateFriendRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :friend_requests do |t|
      t.belongs_to :amahi_user, index: true
      t.belongs_to :system, index: true
      t.integer :status, default: 1
      t.string :pin
      t.string :invite_token
      t.datetime :last_requested_at

      t.timestamps
    end
  end
end
