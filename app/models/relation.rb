class Relation < ActiveRecord::Base
	belongs_to :user
	belongs_to :tag
	has_many_and_belongs_to_many :links

	def self.build(tags, link)
		tags.each {|tag_word|
	
			# enregistre le tag
			
			tag = Tag.find(:first, :conditions => ["word = ?",tag_word]) #On vŽrifie la non existence du twit
		    if !tag
		    	tag = Tag.create(:word => tag_word)
		    end
			
			# crŽer/incrŽmente la relation

			relation = Relation.find(:conditions["user_id = ? and tag_id = ?",link.tweet.user.id, tag.id])
			if !relation
				relation = Relation.create(:user_id => link.tweet.user.id, :tag_id => tag.id)
			end
			relation.links << link
	end  
	
	def weight
		weight = links.length
		return weight
	end		    
	
end
