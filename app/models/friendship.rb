class Friendship < ActiveRecord::Base
  belongs_to :user_to, :foreign_key => "user_to_id", :class_name => "User"
  belongs_to :user_from, :foreign_key => "user_from_id", :class_name => "User"
 
    TYPES = ["follow","adress","interests","retwit"]


  def self.add_new(ut,uf,friendType,options = nil)

	 if !TYPES.include?(friendType)
	    puts "Problem with the type of the frienship,"
	    puts friendType
        return
	 end
   	 
	 fship = self.find(:first, :conditions => ["user_from_id = ? AND user_to_id = ? AND friendType = ?",uf.id,ut.id,friendType])

	 if !fship || (options && options[:value] != fship.value)
		f =  self.create(:user_from_id => uf.id, :user_to_id => ut.id, :friendType => friendType)
		if !options.nil? && options[:value]
			#Options is used to store informations like the twit id of the twit who link the two users
			f.value = options[:value]
		end
	 end
	 return f
  end
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
   puts "[debug]conditions :"+conditions

	 if !friendType.nil? && TYPES.include?(friendType)
         conditions[0] += " AND friendType = ?"
         conditions.push(u.id)		 
	 end

	 friendships = self.find(:all,:conditions => conditions)
	 

	 friendships.collect{|f|
		 {
		  :friendship => (f.user_to == u ? "from" : "to"),
		  :friend => (f.user_to == u ? f.user_from : f.user_to) ,
      :friendType => f.friendType,
			:weigth => f.eval
		 }
	 }
  end
	def self.reco(u)
	  friends = self.findFriends(u)
		friendships = {}
		friends.each{|f|
		  if friendships[f.friend.id].nil? 
			   friendships[f.friend.id] = {:weight => f.weight, :user => f.friend}
			else
			   friendships[f.friend.id][:weight] += f.weight
			end
		}
		return friendships.to_a.collect{|i| i[1]}
	end
	def eval
	   #We should make a better function here to a better recommandation
	    weight = 0;
			if friendType == "follow" #&& friendship == "from"
				weight = 1
			#elsif friendType == "follow" && friendship == "to"
			#	weight = 1
			#elsif friendType == "adress" && friendship == "to"
			#	weight = 4	
			elsif friendType == "adress" #&& friendship == "from"
				weight = 10
			end		
			
	end
  def self.get_note(u1,u2)
	  fships = self.find(:all, :conditions => ["(user_from_id = ? AND user_to_id = ?) OR (user_from_id = ? AND user_to_id = ?)",u1.id,u2.id,u2.id,u1.id])
		weight = 0
		fships.each{|f|
       weight += f.eval
		}
		return weight
	end
end


