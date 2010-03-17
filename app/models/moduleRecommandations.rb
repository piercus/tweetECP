
module Recommandation
  def recommand(fnOther,fnMore,n,factor = 1)
	#  recommand(fnChairToApples,fnSelfToChairs,n,factor)
	#  Let Apple be the class of objects we want to recommand and self be the object we have
	#  Let Chair be another class of objects that we can find from self
	#  then fnSelfToChairs is a method of self to find chair
	#  and fnChairToApples is a method of Chair to find apples
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
			return recos 
	end
  def last_tweets(n = 5)
	  
	 return  self.tweets[-n..-1] if n < self.tweets.size
	 return  self.tweets || []
	end
	def last_links(n = 5)  
	 return  self.links[-n..-1] if n < self.links.size
	 return  self.links || []
	end
end
