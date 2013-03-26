class AddUserCountToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :user_count, :integer
  end
end
