class CreateTweets < ActiveRecord::Migration
  def self.up
    create_table :tweets do |t|
      t.column :text, 		:string
      t.column :user_id, 	:string
      t.column   :t_date, 	:date
      t.timestamps
    end
  end

  def self.down
    drop_table :tweets
  end
end
