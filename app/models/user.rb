class User < ActiveRecord::Base
  validates_uniqueness_of :screen_name
	has_many :tweets
	has_many :relations
  has_many :friends_to, :foreign_key => "user_to_id", :class_name => "Friendship"
  has_many :friends_from, :foreign_key => "user_from_id", :class_name => "Friendship"
	require 'twitter'
	
	def user_timeline(query={})
		# La fonction user_timeline est disponible à partir de l'API REST mais pas à partir de l'API "twitter", j'ai refait la fonction à la main 
		HTTParty.get('http://twitter.com/statuses/user_timeline.json', :query => query)
  end
	def add_followers(users)
	  users.each{|u|
		  fship = Friendship.find(:first, :conditions => ["friends_from = ? AND friends_to = ? AND friendType = ?",self.id,u.id,"follow"])
		}
	end
  def get_followers
		HTTParty.get('http://api.twitter.com/1/statuses/followers.json', :query => {:user_id => twitter_id })
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
  def self.get_twitter_user_from_name(u)
	  return Twitter.user(u)
	end
  def self.set_user_from_twit(twitter_user)
			user = User.find(:first, :conditions => ["screen_name = ?",twitter_user.screen_name])
			if !user
				user = User.create!( :screen_name => twitter_user.screen_name ,:name => twitter_user.name , :twitter_id => twitter_user.id, :nfollowers => twitter_user.followers_count, :nfollowing => twitter_user.friends_count)
			end
			# On récupère les tweets par l'API Twitter
			user.get_tweets
			return user
	end
	def self.set_users_from_twitter_users(twitter_users)
	  #We have a list of twitter users and we want a list of users in database
	  twitter_users.collect{|u|
		  self.set_user_from_twit(u)
		}
	end
	def self.set_users_from_name(users)
	  #We have a list of users names and we want a list of users in database
		require 'twitter'
		users.each{|u|
		  twitter_user = self.get_twitter_user_from_name(u)
			self.set_user_from_twit(twitter_user)
		}
	end
      
end
