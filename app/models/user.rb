class User < ActiveRecord::Base
  	validates_uniqueness_of :screen_name
	has_many :tweets
	has_many :relations
	
	require 'twitter'
	
	def user_timeline(query={})
		# La fonction user_timeline est disponible à partir de l'API REST mais pas à partir de l'API "twitter", j'ai refait la fonction à la main 
		HTTParty.get('http://twitter.com/statuses/user_timeline.json', :query => query)
  	end
	
	def get_tweets
	  	# G:Comment détecter les tweets déja récupérés ?
	  	# P:On utilise le twitter_id qui est fourni par twitter et on vérifie son unicité 
		twits = self.user_timeline(:id => self.twitter_id)
		twits.each {|twit|
			if !Tweet.find(:first, :conditions => ["twitter_id = ?",twit["id"]])#On vérifie la non existence du twit
		    	tweet = Tweet.create(:twitter_id =>twit["id"], :text => twit["text"], :t_date => twit["created_at"], :user_id => self.id)
				# On récupère les liens depuis les tweets
				tweet.load_links
			end
		}
	end


  	def get_taglist
		relations.collect{|r| {:label => r.label, :weight => r.weight} }
	end

      
	def self.set_users(users)
		require 'twitter'
		users.each{|u|
			twitter_user =  Twitter.user(u)
			user = User.find(:first, :conditions => ["screen_name = ?",twitter_user.screen_name])
			if !user
				user = User.create!( :screen_name => twit_user.screen_name ,:name => twit_user.name , :twitter_id => twit_user.id, :nfollowers => twit_user.followers_count, :nfollowing => twit_user.friends_count)
			end
			# On récupère les tweets par l'API Twitter
			user.get_tweets
		}
	end
      
end
