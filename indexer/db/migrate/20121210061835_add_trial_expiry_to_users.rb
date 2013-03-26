class AddTrialExpiryToUsers < ActiveRecord::Migration
  def change
    add_column :users, :trial_expiry, :datetime
  end
end
