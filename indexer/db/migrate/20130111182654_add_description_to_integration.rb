class AddDescriptionToIntegration < ActiveRecord::Migration
  def change
    add_column :integrations, :description, :string
  end
end
