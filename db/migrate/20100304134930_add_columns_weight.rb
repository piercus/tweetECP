class AddColumnsWeight < ActiveRecord::Migration
  def self.up	  
	  add_column :tags, :weight, :integer
	  add_column :relations, :weight, :integer
  end

  def self.down
	  remove_column :tags, :weight
		remove_column :relations, :weight
  end
end
