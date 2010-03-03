class Friendship < ActiveRecord::Base
  belongs_to :user_to, :foreign_key => "user_to", :class_name => "User"
  belongs_to :user_from, :foreign_key => "user_from", :class_name => "User"

end