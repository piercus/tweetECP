class AddAssociationsReferenceAndRelationsAndFollowers < ActiveRecord::Migration
  def self.up
	  create_table :relations_links do |t|
    end
		create_table :followers_users do |t|
		end
		
		add_column :links, :follower_id, :integer
		
  end

  def self.down
  end
end
