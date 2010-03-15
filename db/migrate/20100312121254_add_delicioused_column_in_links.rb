class AddDeliciousedColumnInLinks < ActiveRecord::Migration
  def self.up
	  add_column :links, :delicioused, :boolean
  end

  def self.down
	  remove_column :links, :delicioused
  end
end
