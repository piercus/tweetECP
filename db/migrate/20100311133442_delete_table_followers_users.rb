class DeleteTableFollowersUsers < ActiveRecord::Migration
  def self.up
	  drop_table :followers_users
  end

  def self.down
  end
end
