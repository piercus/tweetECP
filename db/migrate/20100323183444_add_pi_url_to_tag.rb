class AddPiUrlToTag < ActiveRecord::Migration
  def self.up
	  add_column :tags, :pic_url, :string
  end

  def self.down
	  remove_column :tags, :pic_url
  end
end
