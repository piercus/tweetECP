class Addreferencesonlinks < ActiveRecord::Migration
  def self.up
	  add_column :links, :reference_id, :integer
  end

  def self.down
	  remove_column :links, :reference_id
  end
end
