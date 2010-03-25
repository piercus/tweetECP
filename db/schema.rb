# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100324191731) do

  create_table "friendships", :force => true do |t|
    t.integer  "user_from_id"
    t.integer  "user_to_id"
    t.string   "friendType"
    t.integer  "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "links", :force => true do |t|
    t.string   "url"
    t.date     "post_date"
    t.integer  "tweet_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "original"
    t.integer  "follower_id"
    t.integer  "reference_id"
    t.boolean  "delicioused"
    t.string   "description"
  end

  create_table "links_relations", :id => false, :force => true do |t|
    t.integer "link_id",     :null => false
    t.integer "relation_id", :null => false
  end

  create_table "relations", :force => true do |t|
    t.integer  "user_id"
    t.integer  "tag_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "weight"
  end

  create_table "tags", :force => true do |t|
    t.string   "word"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "rareness"
    t.integer  "weight"
    t.integer  "rank"
    t.string   "pic_url"
  end

  create_table "tweets", :force => true do |t|
    t.string   "text"
    t.string   "user_id"
    t.date     "t_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "twitter_id", :null => false
  end

  create_table "users", :force => true do |t|
    t.integer  "nfollowers"
    t.integer  "nfollowing"
    t.string   "name"
    t.integer  "twitter_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "screen_name"
    t.string   "pic_url"
    t.string   "description"
    t.string   "location"
    t.integer  "hubs"
    t.integer  "auth"
  end

end
