class Tweet < ActiveRecord::Base
	validates_uniqueness_of :twitter_id
	has_many :links
	belongs_to :user
	def self.load_links
	  self.all.each{|t|
		  t.load_links
		}
	end
	def load_links
   	# créer un objet Link pour chaque URL du tweet
    	require 'uri'
			links = self.links
			if links.size == 0
				urls = URI.extract(text)
				urls.each {|urlArray|
					l = Link.create(:url => urlArray, :tweet_id => self.id, :post_date => self.t_date)
					if l.get_original_link
					  l.get_delicious_tags
					end
					links.push(l)
				}
			end
			return links
	end
	def self.load_arobases
	  self.all.each{|t|
		  t.load_arobases
		}
	end
	def load_arobases
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
		   puts "[info]Adding a @ relationnship"
	     friends = User.set_users_from_name(list)
			 puts"[debug]Friends : "+friends.inspect+list.inspect
		   self.user.add_address(friends,self.id)
		 end
	end
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
