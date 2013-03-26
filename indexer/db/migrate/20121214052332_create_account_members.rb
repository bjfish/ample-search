class CreateAccountMembers < ActiveRecord::Migration
  def change
    create_table :account_members do |t|
      t.integer :user_id
      t.integer :account_id
      t.string :email, :null => false, :default => ""
      t.timestamps
    end
  end
end
