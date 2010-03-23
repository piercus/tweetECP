class User < ActiveRecord::Base
  validates_uniqueness_of :screen_name
	has_many :tweets
	has_many :relations
  has_many :friends_to, :foreign_key => "user_to_id", :class_name => "Friendship"
  has_many :friends_from, :foreign_key => "user_from_id", :class_name => "Friendship"
	require 'twitter'
	
	# We import the moduleRecommandations module
  require File.dirname(__FILE__) + '/moduleRecommandations'
	include Recommandation

############################################################################

                      # PART A : Class Methods

############################################################################

    ########################################################################
    # A. I. Connection Method
    #   
    # Methods which takes elements from the Twitter API
    ########################################################################
    
    # ___ DEPRECIATED ___ #
    # U is a name of twitter account (screen_name), this method can be used to debug in console
    def self.get_twitter_user_from_name(u)
  	  return Twitter.user(u)
  	end

	  # Takes a twitter user, creates the user in the database, and retrieve its tweets (get_tweets)
    def self.set_user_from_twitter(twitter_user) 
  	  if twitter_user.kind_of?(Hash)
  			user = User.find(:first, :conditions => ["screen_name = ? OR twitter_id = ?",twitter_user["screen_name"],twitter_user["id"]])
  			if !user
  				user = User.create!( :screen_name => twitter_user["screen_name"] ,:name => twitter_user["name"] , :twitter_id => twitter_user["id"], :nfollowers => twitter_user["followers_count"], :nfollowing => twitter_user["friends_count"], :description => twitter_user["description"], :location => twitter_user["location"])
  			  user.get_tweets
  			end
  			return user
  		else
  		  puts "[Error] Problem with the following user in set_user_from_twitter: \n"+twitter_user.inspect 
  		end
  	end

	  # Takes a list of twitter users and return a list of users in database
  	def self.set_users_from_twitter_users(twitter_users,n = nil)
		  total_count = 0
			twitter_users.each{|u| total_count += u["followers_count"]}
  	  
			twitter_users.collect{|u| 
			  if n != nil
			    prob = u["followers_count"].to_f/total_count*n
			    if (prob > rand )
			      self.set_user_from_twitter(u)
				  else
					  user = User.find_by_dname(u["name"])
					  if User.find_by_dname(u["name"])
					    nil
						else
						  
						end
					end
				else
				  self.set_user_from_twitter(u)
				end
			}.compact
  	end

	  # Takes a list of names and return a list of users in database
  	def self.set_users_from_name(users)
  		require 'twitter'
  		localUsers = []

  		users.each{|u|
  		  twitter_user = Twitter.user(u)
  			localU = self.set_user_from_twitter(twitter_user)
  			localUsers.push(localU)
  		}
  		return localUsers
  	end
    def self.add_followers_to_each
		  users = self.all
			users.each{|u|
			  u.get_more_users(1,3)
			}
		end
    ########################################################################
    # A. II. Finder Methods
    #   
    ########################################################################

  	def self.find_by_dname(key)
  	  return self.find_by_screen_name(key)
  	end

  	def self.find_by_dname_like(key)
  	  self.find(:all,:conditions => ["screen_name like ?", key.concat("%")])
  	end

    ########################################################################
  	# A. III. Recommandation
  	#   
  	# Test to use the algorithm for recommandations of google : Hubs and Authority
  	# http://en.wikipedia.org/wiki/HITS_algorithm
    ########################################################################

  	def self.HubsAndAuthority(n)
  	  users = self.all
  		list = {}
  		users.each{|u|
  		  list[u.id.to_s] = {
  			  :auth => 1,
  			  :hub => 1
  			}
  		}
  		n.times {
  			users.each{|u|
  				u.followings.each{|f|
  					list[u.id.to_s][:auth] +=  list[f[:friend].id.to_s][:hub]
  				}
  			}
  			users.each{|u|
  				u.followers.each{|f|
  					list[u.id.to_s][:hub] +=  list[f[:friend].id.to_s][:auth]
  				}
  			}				

  		}
			list.each_pair{|key,value|
			  u = self.find(key)
				u.auth = value[:auth]
				u.hubs = value[:hub]
				u.save
			}
      return list
  	end


############################################################################

                      # PART B : Instance Methods

############################################################################


  ########################################################################
	# B. I . Naming and alias Methods 
	#   
	#   for the consolidations of names with the object Tag
	#   dname is for "display name"
  ########################################################################
	
	########################################################################
	# I.1 : Simple getters
	
	def dname
	  return screen_name
	end

	# Returns an array containing ALL the links tweeted bu the user
  def links
	  self.tweets.collect{|t| t.links}.flatten.compact
	end

	########################################################################
	# I.2 : getters for the recommamndation system, the function recommand is in the module Recommandation, 
	# the whole recommandation system is based on this function
	#  recommand(fnChairToApples,fnSelfToChairs,n,factor)

	def get_best_users(n,factor = 1)
	  return recommand(:get_best_users,:get_best_tags,n,factor){
		  self.friends.collect{|f|		
			# See comments about frienships relations to more information about f structure
			  [f[:friend],f[:friend].screen_name,f[:weight]*factor]
		  }
		}	
	end 
	def get_best_tags(n,factor = 1)
	  return recommand(:get_best_tags,:get_best_users,n,factor){
		  self.relations.collect{|r|
			  (r.tag.nil? ? nil : [r.tag,r.tag.word,(r.weight || r.get_weight)*factor])
		  }.compact
		}
	end
	
	#################################################
	# B. II . Connection Method
	#   
	# here are methods which takes elements from Web
	##############################################
	
	########################################################################
	# II.1 Extend Twitter API to get twitter's infos with HTTParty
	
	def user_timeline(query={})
		# La fonction user_timeline est disponible à partir de l'API REST mais pas à partir de l'API "twitter", j'ai refait la fonction à la main 
		HTTParty.get('http://twitter.com/statuses/user_timeline.json', :query => query)
  end	
	
	def get_followers
		HTTParty.get('http://api.twitter.com/1/statuses/followers.json', :query => {:user_id => twitter_id })
	end	
	def get_following
		HTTParty.get('http://api.twitter.com/1/statuses/friends.json', :query => {:user_id => twitter_id })
	end		
	########################################################################
	# II.2 Process to take elements from the web
	
	def get_more_users(l=1,n = nil)
	  #u is a User in the database
		#l is the level of recursivity
		if l != 0
      #call the API
			#fws = self.get_followers
			fi = self.get_following
			#from the API objects create databases objects   
	    users = User.set_users_from_twitter_users(fi,n)
      self.add_followings(users)
	    users.each{|f|
			  f.get_more_users(l-1, n)
			}
		end
		return users
  end

	def get_tweets
		twits = self.user_timeline(:id => self.twitter_id)
		twits.each {|twit|
		  if twit.kind_of?(Hash)#debug because we find tweets like ["request", "/statuses/user_timeline.json?id=46259780"]
			  if !Tweet.find(:first, :conditions => ["twitter_id = ?",twit["id"]])#On vérifie la non existence du twit
		    	  tweet = Tweet.create(:twitter_id =>twit["id"].to_i, :text => twit["text"], :t_date => twit["created_at"], :user_id => self.id)
				  # On récupère les liens depuis les tweets
				  tweet.load_links
				  tweet.load_arobases
			  end
			else
			  puts "Problem with the following twit in get_tweets : \n"+twit.inspect 
			end
			
		}
	end

	#################################################
	# B. III . Friendship methods
	#   
	#  Friendship is a model to create n-n links between the table user and itself
	#  It's a full model to store all the informations about the friendship
	#  then we can make lot of methods to interrogate this links
	##############################################
  
	## III.1 Setters, create links between users
	
	def add_followers(users)
	  users.each{|u|
		  Friendship.add_new(self,u,"follow")
		}
	end
  def add_address(users,tweet_ref)#correspond to the @ in tweet, call in tweet.rb
	  #here self adress a tweet to users
		users.each{|u|
		  Friendship.add_new(u,self,"address",tweet_ref)
		}
	end
	def add_followings(users)
	  users.each{|u|
		  Friendship.add_new(u,self,"follow")
		}
	end
	## III.1 getters, ask links between users	
	
	#  NB : 
	#
	# Friendships Getters
	# The output format is like 
	# :weight => 1, // an arbitrary value to classify friendships  
	# :friendType=>"from" or "to" // is self the user who make the friendships or is it the other
	# :friend => Friend Object 
	# :friendType => "follow" or "address"
	
  def followers
	  Friendship.findFriends(self,"follow","from")
  end  
  
  def followings
	  Friendship.findFriends(self,"follow","to")
  end
  
  def friends
     Friendship.findFriends(self)
  end

end
