module Recommandation

  def recommand(fnOther,fnMore,n,factor = 1)
	#  recommand(fnChairToApples,fnSelfToChairs,n,factor)
	#  Let Apple be the class of objects we want to recommand and self be the object we have
	#  Let Chair be another class of objects that we can find from self
	#  then fnSelfToChairs is a method of self to find chair
	#  and fnChairToApples is a method of Chair to find apples
	#
	#  n : number of apples we want to recommand

      # recos is an array of array : [ [object,object.dname,weight], ... ]
      recos = []
		  return [] if factor < 0.1

      recos = yield
		  s = recos.size()
		 
			# If there's not enough recos, recursively add new elements
			if s < n
				more_recos = [];
				other_objs = self.send(fnMore,(n-s))
				more_reco = []
				other_objs.each{|o|
				  more_reco.concat(o[0].send(fnOther,(n-s),factor*1/2))
				}
				recos.concat(more_reco)
			end
			
			# Delete the dname doubles
			recosU = []
			keys = recos.collect{|x| x[1]}.uniq
			recos.each{|r|
			  if keys.include? r[1]
				  recosU.push(r)
					keys.delete(r[1])
				end
				# Here we could had a function to add a weight when the thing is repetitive
			}
			recos = recosU
			
			# Sort the array from highest weight to smallest weight. Then keep the n first.
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
