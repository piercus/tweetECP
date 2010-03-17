module Recommandation
  def recommand(fnOther,fnMore,n,factor = 1, outputType = "array")
	   recos = []
		 return [] if factor < 0.1

     recos = yield
			
			# recursively add new elements
			if recos.size < n
			  s = recos.size()
				more_recos = [];
				
				other_objs = self.send(fnMore,(n-s))
				more_reco = []
				other_objs.each{|o|
				  more_reco.concat(o[0].send(fnOther,(n-s),factor*1/2))
				}
				recos.concat(more_reco)
			end
			
			#verify the uniqueness
			recosU = []
			keys = recos.collect{|x| x[1]}.uniq
			recos.each{|r|
			  if keys.include? r[1]
				  recosU.push(r)
					keys.delete(r[1])
				end
				#here we could had a function to add a weight when the thing is repetitive
			}
			recos = recosU
			
			# sort the array and cut it
			recos.sort!{|x,y| y[2] <=> x[2]}
			recos = recos[0..n-1]
			return recos if outputType == "array"
			if outputType == "display"
			  out = {}
				recos.each{|r| out[r[1]] = [r[2], self.get_url] }
				return out
			end
	end
  def get_url
	  return url_for :controller => "welcome", :action => "search",:type => self.class.to_s.downcase, :id => self.dname
	end
end
class Tag < ActiveRecord::Base
	belongs_to :link
	has_many :relations
	include Recommandation
	def self.set_weight
	  self.all.each{|t|
	    t.set_weight
			t.save!
	  }
	end
	def dname
	  return word
	end
	def self.find_by_dname_like(key)
	  self.find(:all,:conditions => ["word like ?", key.concat("%")])
	end
	def tweets
	  self.links.collect{|l| l.tweet}
	end
	def self.find_by_dname(key)
	  return self.find_by_word(key)
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
  def self.recomand(object, n = 20)
	  className = object.class.to_s
		if className == "User"
		  u= object
			return u.get_best_tags(n) 
		elsif className == "Tag"
		  tag = object
		  users = []
			tag.relations.each{|r|
			  users.push({:user => r.user, :weight => r.strengh})
			}
			return {:users => users}
		end
	end
	def get_best_users(n, factor = 1, outputType = "array")
		return recommand(:get_best_users,:get_best_tags,n,factor, outputType){
			  self.relations.collect{|r|
			    [r.user,r.user.screen_name,(r.weight || r.get_weight)*factor]
			  }
			}
	end
	def links 
		return self.relations.collect{|r| r.links }.flatten
	end
	def get_best_tags(n, factor = 1, outputType = "array")
	  return recommand(:get_best_tags,:get_best_users,n,factor,outputType){
		 self.links.collect{|l| l.tags }.flatten.collect{|t| [t,t.word,t.weight*factor];}
		}
	end
end

