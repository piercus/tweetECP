class Friendship < ActiveRecord::Base
<<<<<<< HEAD
  belongs_to :user_to, :foreign_key => "user_to_id", :class_name => "User"
  belongs_to :user_from, :foreign_key => "user_from_id", :class_name => "User"
end
=======
  belongs_to :user_to, :foreign_key => "user_to", :class_name => "User"
  belongs_to :user_from, :foreign_key => "user_from", :class_name => "User"

end
>>>>>>> f3a98ebb8d7eb41237a27fc60b789002736204f8
