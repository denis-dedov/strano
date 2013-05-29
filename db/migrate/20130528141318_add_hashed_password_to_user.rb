class AddHashedPasswordToUser < ActiveRecord::Migration
  def change
    add_column :users, :hashed_password, :string, limit: 40, default: '', null: false
  end
end
