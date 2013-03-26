class CreateIntegrations < ActiveRecord::Migration
  def change
    create_table :integrations do |t|
      t.string :name
      t.string :url
      t.string :auth_type

      t.timestamps
    end
  end
end
