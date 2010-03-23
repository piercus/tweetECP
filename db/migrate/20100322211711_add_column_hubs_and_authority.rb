class AddColumnHubsAndAuthority < ActiveRecord::Migration
  def self.up
	  add_column :users, :hubs, :integer
	  add_column :users, :auth, :integer
	  add_column :tags, :hubs, :integer
	  add_column :tags, :auth, :integer
  end

  def self.down
		  remove_column :users, :hubs
		  remove_column :users, :auth
		  remove_column :tags, :hubs
		  remove_column :tags, :auth

  end
end
