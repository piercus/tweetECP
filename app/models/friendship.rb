class Friendship < ActiveRecord::Base
  belongs_to :user_to, :foreign_key => "user_to_id", :class_name => "User"
  belongs_to :user_from, :foreign_key => "user_from_id", :class_name => "User"
 
    TYPES = ["follow","adress","interests","retwit"]


  def self.add_new(ut,uf,ftype,options = nil)

	 if !TYPES.include?(ftype)
	    puts "Problem with the type of the frienship,"
	    puts ftype
        return
	 end
   	 
	 fship = self.find(:first, :conditions => ["user_from_id = ? AND user_to_id = ? AND friendType = ?",uf.id,ut.id,ftype])

	 if !fship || (options && options[:value] != fship.value)
		f =  self.create(:user_from_id => uf.id, :user_to_id => ut.id, :friendType => ftype)
		if !options.nil? && options[:value]
			#Options is used to store informations like the twit id of the twit who link the two users
			f.value = options[:value]
		end
	 end
	 return f
  end
  def self.findFriends(u,ftype = nil,sens = "none")
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
    

	 if !ftype.nil? && TYPES.include?(ftype)
         conditions[0] += "AND friendType = ?"
         conditions.push(u.id)		 
	 end

	 friendships = self.find(:all,:conditions => conditions)
	 friendships.collect{|f|
		 {
		  :friendship => (f.user_to == u ? "from" : "to") 
		  :friend => (f.user_to == u ? f.user_from : f.user_to) 
          :type => f.friendType
		 }
	 }
  end

end


