class Tweet < ActiveRecord::Base
	validates_uniqueness_of :twitter_id
	has_many :links
	belongs_to :user
	
	def load_links
   	# créer un objet Link pour chaque URL du tweet
    	require 'uri' 
    	urls = URI.extract(text)
        urls.each {|urlArray|
			Link.create(:url => urlArray, :tweet_id => self.id, :post_date => self.t_date)
		}
	end
	def load_arobases
	   text = self.text
		list = []
	   regexp = /@[a-zA-Z]*/
		name = text[regexp]

	   while(name != nil){
		   list.push(name[1..-1])
		   text = text.sub(regexp,"")
		   name = text[regexp]	   }
	   u = User.set_users_from_name(list)

	end
	
end
