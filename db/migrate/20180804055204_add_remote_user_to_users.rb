class AddRemoteUserToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :remote_user, :string
  end
end
