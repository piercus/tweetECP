class CreateLinks < ActiveRecord::Migration
  def self.up
    create_table :links do |t|
      t.column :url, :string
			t.column :post_date, :date
			t.column :tweet_id, :integer
      t.timestamps
    end
  end

  def self.down
    drop_table :links
  end
end
