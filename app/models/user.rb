class User < ActiveRecord::Base
  validates_uniqueness_of :screen_name
	has_many :tweets
		
	require 'twitter'#gem correspondant : twitter	
	
	def get_tweets
	  # retrieve the user's tweets. Mais lesquels ?
	  # G:Comment détecter les tweets déja récupérés ?
	  # P:On utilise le twitter_id qui est fourni par twitter et on vérifie son unicité 
    twits = self.user_timeline(:id => self.twitter_id)
		twits.each {|twit|
		  if !Tweet.find(:first, :conditions => ["twitter_id = ?",twit["id"]])#On vérifie la non existence du twit
		    tweet = Tweet.create(:twitter_id =>twit["id"], :text => twit["text"], :t_date => twit["created_at"], :user_id => self.id)
			end
		}
	end
	
	def user_timeline(query={})
	  # La fonction user_timeline est disponible à partir de l'API REST mais pas à partir de l'API "twitter", j'ai refait la fonction à la main 
	  HTTParty.get('http://twitter.com/statuses/user_timeline.json', :query => query)
  end
    
end
