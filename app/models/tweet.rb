class Tweet < ActiveRecord::Base
	validates_uniqueness_of :twitter_id
	has_many :links
	belongs_to :user
	after_create :after_creation 
	
	
	#######################
	#    Before Filter
	#######################
	def after_creation 
	   # On récupère les liens depuis les tweets
		self.load_links
		#Ainsi que ceux à qui ils s'adressaient
		self.load_arobases(0)
	end
	def load_links
   	# créer un objet Link pour chaque URL du tweet
    	require 'uri'
			links = self.links
			if links.size == 0
				urls = URI.extract(text)
				urls.each {|urlArray|
				  #verify that there ain't no such link in tha database
					l = Link.create(:url => urlArray, :tweet_id => self.id, :post_date => self.t_date)
					if l.valid?
					  if l.get_original_link
					    l.get_delicious_tags
					  end
					  links.push(l)
					end
				}
			end
			return links
	end
	def self.load_arobases(n=0)
	  self.all.each{|t|
		  t.load_arobases(n=0)
		}
	end
	def load_arobases(l=0)
	  text = self.text
		list = []
	  regexp = /@[a-zA-Z]*/
		name = text[regexp]

	   while name != nil do 
		   list.push(name[1..-1])
		   text = text.sub(regexp,"")
		   name = text[regexp]	   
		 end
		 if list.length != 0
	     friends = User.set_users_from_name(list,l)
		   self.user.add_address(friends,self.id)
		 end
	end
	
	#######################
	#       Maintenance
	#########################
	
	def remove_doubles
	  Tweet.find(:all,:conditions => ["twitter_id = ?",self.twitter_id]).each{|t|
		  if t != self
			 t.delete
			 puts "Delete : "+t.inspect
			end
		}
	end
	def self.clean
	  list = []
	  self.all.each{|t|
		  if !list.include? t.twitter_id
		    t.remove_doubles		  
			end
			list.push(t.twitter_id)
		}
	end
end
