class CreateFriendships < ActiveRecord::Migration
  def self.up
    create_table :friendships do |t|
      t.column :user_from_id, :integer
      t.column :user_to_id, :integer
			t.column :friendType, :string
			t.column :value, :integer
			t.timestamps
    end
  end

  def self.down
    drop_table :friendships
  end
end
