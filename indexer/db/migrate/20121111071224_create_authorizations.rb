class CreateAuthorizations < ActiveRecord::Migration
  def change
    create_table :authorizations do |t|
      t.string :token
	    t.string :secret
      t.integer :user_id, :null => false
      t.integer :integration_id, :null => false
      t.timestamps
    end
  end
end
