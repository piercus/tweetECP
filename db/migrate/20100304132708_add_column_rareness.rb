class AddColumnRareness < ActiveRecord::Migration
  def self.up
	  add_column :tags, :rareness, :integer
  end

  def self.down
	 remove_colmun :tags, :rareness
  end
end
