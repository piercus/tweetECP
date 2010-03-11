class AddUrlPhotoUser < ActiveRecord::Migration
  def self.up
	  add_column :users, :pic_url, :string
	  add_column :users, :description, :string
  end

  def self.down
	  remove_column :users, :pic_url
		remove_column :users, :description
  end
end
