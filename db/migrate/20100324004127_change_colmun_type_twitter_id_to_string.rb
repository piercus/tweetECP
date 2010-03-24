class ChangeColmunTypeTwitterIdToString < ActiveRecord::Migration
  def self.up
	  change_column :tweets, :twitter_id, :string, :null => false
  end

  def self.down
	  change_column :tweets, :twitter_id, :integer
  end
end
