class Friendship < ActiveRecord::Base
  belongs_to :user_to, :foreign_key => "user_to_id", :class_name => "User"
  belongs_to :user_from, :foreign_key => "user_from_id", :class_name => "User"
 
    TYPES = ["follow","address","interests","retweet"]

	#################################################
	#
	#  I. Class Methods, Setters or getters
	#   
	##############################################
	
	
  #	  Add a new friendship
  # 	Global setter to create friendships

	def self.add_new(ut,uf,friendType, value = nil)

	 if !TYPES.include?(friendType)
	    puts "Problem with the type of the frienship,"
	    puts friendType
      return
	 end
   conditions = ["user_from_id = ? AND user_to_id = ? AND friendType = ?",uf.id,ut.id,friendType]
	 #For the fType adress, we verify that the reference has been made on the same tweet, we then use the value column
	 if friendType == "adress"
	   raise "Must have a tweet id in parameter" if value.nil?
	   conditions[0] += " AND value == ?"
		 conditions.push(value)
	 end
	 fship = self.find(:first, :conditions => conditions)

	 if !fship 
		f =  self.create(:user_from_id => uf.id, :user_to_id => ut.id, :friendType => friendType)
		if value
			#Options is used to store informations like the tweet id of the twit who link the two users
			f.value = value
			f.save!
		end
	 end
	 return f
  end
	
  #	  Get friendships of a user, parameters are options for the finder
  # 	
  def self.findFriends(u,friendType = nil,sens = "none")
     conditions = [""]
	 case sens
       when "to"  
		   conditions[0] += "user_from_id = ?"
		   conditions.push(u.id)
	   when "from" 
		   conditions[0] += "user_to_id = ?"
		   conditions.push(u.id)
	   when "none"  
		   conditions[0] += "user_from_id = ? OR user_to_id = ?"
		   conditions.push(u.id)
           conditions.push(u.id)
	   else 
		   raise "Error with the sens, bad input"
	 end


	 if !friendType.nil? && TYPES.include?(friendType)
         conditions[0] += " AND friendType = ?"
         conditions.push(friendType)		 
	 end

	 friendships = Friendship.find(:all,:conditions => conditions)

	 friendships.collect{|f|
		 {
		  :friendship => (f.user_to == u ? "from" : "to"),
		  :friend => (f.user_to == u ? f.user_from : f.user_to) ,
      :friendType => f.friendType,
			:weight => f.eval((f.user_to == u ? "to":"from"))
		 }
	 }
  end
	
	#################################################
	#
	#  II. Instance Methods
	#   
	##############################################

	#	  Make an evaluation
  # 	
	def eval(fSens = nil)
	   if fSens.nil?
	    weight = 0;
			if friendType == "follow" #&& friendship == "from"
				weight = 1
			elsif friendType == "address" #&& friendship == "from"
				weight = 10
			end		
		else
	    weight = 0;
			if friendType == "follow" && fSens == "to"
				weight = 3
			elsif friendType == "follow" && fSens == "from"
				weight = 1
			elsif friendType == "address" && fSens == "to"
				weight = 10
			elsif friendType == "address" && fSens == "from"
				weight = 5
			end		
		end
			
	end

end


