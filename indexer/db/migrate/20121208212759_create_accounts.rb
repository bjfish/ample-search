class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :stripe_token
      t.string :email
      t.string :description
      t.string :customer_id
      t.string :last_4_digits
      t.integer :creator_id
      t.timestamps
    end
  end
end
