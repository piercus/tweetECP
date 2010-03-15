class Relation < ActiveRecord::Base
	belongs_to :user
	belongs_to :tag
	has_and_belongs_to_many :links

	def self.build(tags, link)
		tags.each {|tag_word|
	
			# enregistre le tag
			
			tag = Tag.find(:first, :conditions => ["word = ?",tag_word]) #On vŽrifie la non existence du twit
		    if !tag
		    	tag = Tag.create(:word => tag_word)
		    end
			
			# crŽer/incrŽmente la relation

			relation = Relation.find(:first, :conditions => ["user_id = ? and tag_id = ?",link.tweet.user.id, tag.id])
			if !relation
				relation = Relation.create(:user_id => link.tweet.user.id, :tag_id => tag.id)
			end
			link.relations << relation if !link.relations.include?(relation)
		}
	end  
	
	def set_weight
		self.weight = links.length
		self.save
		return self.weight
	end		    
	def get_weight
	  set_weight if !weight
		return weight
	end
	def strenght
	  self.weight/self.tag.popularity
	end
	
end
