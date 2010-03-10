class Tweet < ActiveRecord::Base
	validates_uniqueness_of :twitter_id
	has_many :links
	belongs_to :user
	
	def load_links
   	# créer un objet Link pour chaque URL du tweet
    	require 'uri' 
    	urls = URI.extract(text)
      urls.each {|urlArray|
			  l = Link.create(:url => urlArray, :tweet_id => self.id, :post_date => self.t_date)
			  l.get_original_link
				l.get_delicious_tags
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
	   u = User.set_users_from_name(list)
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
