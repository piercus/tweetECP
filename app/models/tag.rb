
class Tag < ActiveRecord::Base
	belongs_to :link
	has_many :relations
	require File.dirname(__FILE__) + '/moduleRecommandations'
	include Recommandation
	############################################################################

                      # PART A : Class Methods

############################################################################
	
	def self.set_weight
	  self.all.each{|t|
	    t.set_weight
			t.save!
	  }
	end
	
	
	def self.pageRank(n)
	  tags = self.all
  	list = {}
  	tags.each{|t|
  		  list[t.id.to_s] = 1
  	}
  	n.times {
  		tags.each{|t|
  			t.closest.each{|f|
  				list[t.id.to_s] +=  list[f.id.to_s]*f.weight
  			}
  		}
		

  	}
		max_value = 0
		list.each{|i|
		  if i > max_value
			  max_value = i
			end
		}
		list.each_pair{|key,value|
		    
				t = self.find(key)
				t.rank= value*1000/max_value.
				t.save
		}
    return list
	end
	
############################################################################

                      # PART B : Instance Methods

############################################################################
	#################################################
	# I. Naming and alias Methods 
	#   
	#   for the consolidations of names with the object Tag
	#   dname is for "display name"
	##############################################
	def dname
	  return word
	end
	def self.find_by_dname_like(key)
	  tags = self.find(:all,:conditions => ["word like ?", key.concat("%")], :order => "weight DESC")
		return (tags.size>10 ? tags[O..10] : tags)
	end
	def self.find_by_dname(key)
	  return self.find_by_word(key)
	end	
	
	def tweets
	  self.links.collect{|l| l.tweet}
	end
		# Returns the closest tags
	def closest
	  self.get_best_tags(30,0.1).collect{|a| a[0]}
	end
	def links 
		return self.relations.collect{|r| r.links }.flatten
	end
	#################################################
	# II. Recommandations
	#   
	#   the whole recommandation system is based on this function
	#   recommand(fnChairToApples,fnSelfToChairs,n,factor)
	##############################################
	
	# II.1 the whole recommandation system is based on this function
	#   recommand(fnChairToApples,fnSelfToChairs,n,factor)
	
	def get_best_users(n, factor = 1)
		return recommand(:get_best_users,:get_best_tags,n,factor){
			  self.relations.collect{|r|
			    [r.user,r.user.screen_name,(r.weight || r.get_weight)*factor]
			  }
			}
	end	
	def get_best_tags(n, factor = 1)
	  return recommand(:get_best_tags,:get_best_users,n,factor){
		 self.links.collect{|l| l.tags }.flatten.collect{|t| [t,t.word,t.weight*factor];}
		}
	end

	# II.2 : Weight and rareness
	#  
	
	def set_weight
		w = 0
		self.relations.each {|relation|
			w =+ relation.get_weight
		}	
		self.weight = w
		return w
	end
	
	# alias for 
	def popularity
		return weight
	end
	def set_rareness
		self.rareness = (User.all.length/self.weight).to_i
	end
	

end

