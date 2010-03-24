
class Tag < ActiveRecord::Base
  validates_uniqueness_of :word
	has_many :relations
	before_create :find_flickr_photo
	#require 'flickr_fu'
	
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
	def self.clean_up
	self.all.each{|t|
	  if t.word.split.size > 1
		  tags = t.word.split
			ls = t.links
			ls.each{|l|
			  Relation.build(tags,l)
			}
			t.relations.delete_all
			t.delete
		end
		if t.pic_url.nil? && !t.word.blank? && t.word.size > 3
		  t.find_flickr_photo
			t.save
		end
	}
	end
	def self.reco_best(n=10)
	  best = self.all.sort{|x,y| y.rank  <=> x.rank}
		return best.collect{|b| (b.dname.size > 5 ? [b,b.dname,rand*10.to_i] : nil)}.compact[0..n]
	end
	def self.pageRank(n)
	  tags = self.all
  	list = {}
  	tags.each{|t|
  		  list[t.id.to_s] = 1
  	}
  	n.times {
  		tags.each{|t|
  			t.links.each{|f|
  				list[t.id.to_s] +=  list[f.id.to_s].to_i
  			}
  		}

  	
		  max_value = 0
		  list.each_pair{|i,value|  
		    if !list[i].nil? && list[i] > max_value
			    max_value = list[i]
			  end
		  }
			tags.each{|t|
  		  list[t.id.to_s] = list[t.id.to_s]*100/max_value
  	  }
		}
		tags.each{|t|
				t.rank = list[t.id.to_s]*t.weight
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
	  self.links.collect{|l| l.tags }.flatten.compact.collect{|t| t}
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
		 self.links.collect{|l| l.tags }.flatten.compact.collect{|t| [t,t.word,t.weight*factor*(t.rank+1)];}
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
		#################################################
	# III. Flickr Methods
	#   
	##############################################
	def find_flickr_photo
	  flickr = Flickr.new(File.join(RAILS_ROOT, 'config', 'flickr.yml'))
		begin
		  flis =flickr.photos.search(:tags => self.word)
		rescue => e
		  puts "[Error]Error with the flick'r API, Go through : "+self.inspect
			return
		end 
		if flis[1].nil?
		 return 
		end
		begin
      self.pic_url = flis[1].url
		rescue => e
		  puts "[Error]Error with the save of the url comming from twitter api, Go through : "+flis[1].inspect
			return
		end
	end
end

