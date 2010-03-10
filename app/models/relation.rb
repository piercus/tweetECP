class Relation < ActiveRecord::Base
	belongs_to :user
	belongs_to :tag
	has_and_belongs_to_many :links

	def self.build(tags, link)
		tags.each {|tag_word|
	
			# enregistre le tag
			
			tag = Tag.find(:first, :conditions => ["word = ?",tag_word]) #On v�rifie la non existence du twit
		    if !tag
		    	tag = Tag.create(:word => tag_word)
		    end
			
			# cr�er/incr�mente la relation

			relation = Relation.find(:conditions["user_id = ? and tag_id = ?",link.tweet.user.id, tag.id])
			if !relation
				relation = Relation.create(:user_id => link.tweet.user.id, :tag_id => tag.id)
			end
			relation.links << link
		}
	end  
	
	def set_weight
		self.weight = links.length
		return self.weight
	end		    
	def strenght
	  self.weight/self.tag.popularity
	end
	
end
