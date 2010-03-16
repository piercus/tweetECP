class Tag < ActiveRecord::Base
	belongs_to :link
	has_many :links
	has_many :relations
	
	def self.set_weight
	  self.all.each{|t|
	    t.set_weight
			t.save!
	  }
	end
	
	def set_weight
		w = 0
		self.relations.each {|relation|
			w =+ relation.get_weight
		}	
		self.weight = w
		return w
	end
	
	def popularity
		return weight
	end
	def set_rareness
		self.rareness = (User.all.length/self.weight).to_i
	end
  def self.recomand(object, id, n = 20)
		if object == "User"
		  u= User.find(id)
			return u.get_best_tags(n) 
		elsif object == "Link"
		  l = Link.find(id)
			if l.reference
			  l = l.reference
			end
		  url = l.orig_uri
			rel = l.relations
			tags = []
			l.relations.each{|r|
			  #we don't do l.tags to have the strenght of the relation between the tag and the user
				tags.push({
				    :tag => r.tag,
						:weight => r.strenght
						})
			}
      #don't know how tio recommand more ? We could pass by the users but it could make wird results
			#Or we could go to the other level passing by the tag network
			return {:tags => tags}

		elsif object == "Tag"
		  tag = Tag.find(id)
		  users = []
			tag.relations.each{|r|
			  users.push({:user => r.user, :weight => r.strengh})
			}
			return {:users => users}
		end
	end
end

