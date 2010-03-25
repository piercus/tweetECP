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
    
    # U is a name of twitter account (screen_name), this method can be used to debug in console
    def self.get_twitter_user_from_name(u)
  	  return Twitter.user(u)
  	end

	  # Takes a twitter user, creates the user in the database, and retrieve its tweets (get_tweets)
    def self.set_user_from_twitter(twitter_user) 
  	  
			#verify the type Hash
			raise "[Error] Problem with the following user in set_user_from_twitter: \n"+twitter_user.inspect+"The input must be a Hash\n" if !twitter_user.kind_of?(Hash)
			
			
  	  userF = User.find(:first, :conditions => ["screen_name = ? OR twitter_id = ?",twitter_user["screen_name"],twitter_user["id"]])
			# debug puts "[debug, user.b l.35]"+userF.nil?.to_s
			if userF.nil?
			  
				begin
					userF = User.create!( :screen_name => twitter_user["screen_name"] ,:name => twitter_user["name"] , :twitter_id => twitter_user["id"], :nfollowers => twitter_user["followers_count"], :nfollowing => twitter_user["friends_count"], :pic_url => twitter_user["profile_image_url"], :description => twitter_user["description"], :location => twitter_user["location"])
				rescue => e
					puts "[error] While getting the following user :"+twitter_user["screen_name"]+"\nTestValue :"+(userF.nil?).to_s+"\nUser :"+userF.inspect+"\nIn object :"+twitter_user.inspect
					raise e
				end
				userF.save!
				userF.get_tweets
			end
			return userF

  	end

	  # Takes a list of twitter users and return a list of users in database
  	def self.set_users_from_twitter_users(twitter_users,n = nil)
		  total_count = 0
			 
			twitter_users.each{|u| 
			  if u.kind_of?(Hash) && u["followers_count"].kind_of?(Integer)
			    total_count += u["followers_count"]
        else
				  puts "[info] Problem with the following user:"+u.to_s+" that should have followers"
				end
				
			}
  	  
			
			twitter_users.collect{|u| 
				if n != nil
				  #We don't parse each user by just those with lot of followers
					prob = u["followers_count"].to_f/total_count*n
					if (prob > rand )
					  puts "[info] here is a lucky friend ("+u["screen_name"]+") for prob:"+prob.to_s
						self.set_user_from_twitter(u)
					else
						user = User.find_by_dname(u["name"])
					end
				else
					self.set_user_from_twitter(u)
				end
			}.compact
  	end

	  # Takes a list of names and return a list of users in database
  	def self.set_users_from_name(users,n=1)
  		require 'twitter'
  		localUsers = []

  		users.each{|u|
			  if n
  		    twitter_user = Twitter.user(u)
  			  localU = self.set_user_from_twitter(twitter_user)
  			  localUsers.push(localU)
				else
				  localU = self.find_by_dname(u)
					localUsers.push(localU) if localU
				end
  		}
  		return localUsers
  	end
		
		#function to uniformise the database
    def self.add_followers_to_each(n = 3,start = 0)
		  users = self.all
			if start > 0 && start < users.size
			  users = users[start..-1]
			end
			users.each{|u|
			  friends = u.get_more_users(1,n)
				#puts "[info] id:"+u.id+" name:"+u.screen_name +" friends:"+friends.count
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
		
	  def self.reco_best(n=10)
	    best = self.all.sort{|x,y| ( y.auth.nil? ? -1 : ( x.auth.nil? ? 1 : y.auth <=> x.auth))}
		  return best[0..n].collect{|b| [b,b.dname,rand*10.to_i]}
	  end
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
    ########################################################################
  	# A. III. Cleanup
  	#   
    ########################################################################

    def self.clean_up
		  #params of my network
			ipEnd = 125
			ipStart = 110
			ipRadical = "138.195.153."
			file = "sudo ./script/changeIP.sh "

      #twitter parameter
			maxRequest = 140
			
			ip = ipStart
			n = 0
			User.all.each{|u|
			# add a pic_url to each
			   if !u.pic_url
					 if n > maxRequest
						 cmd = file+ipRadical+n.to_s
						 chg = %x[#{cmd}]
						 puts chg
						 n = 0
						 ip += 1
					 end
					 if ip > ipEnd
						 return "not arrived to the end"
					 end
					 begin
					   u.get_pic_url				
					 rescue => e
					   puts u.inspect+"\n----------------------\n"+e.inspect
					 end
					 n += 1
					end
			}
			return "ok"
			
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
	
	#Get the pic_url to fill database
  def get_pic_url
	  if !self.pic_url
		  twit_u = User.get_twitter_user_from_name(self.screen_name)
			puts twit_u
			self.pic_url = twit_u["profile_image_url"]
			self.save!
		end
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
		#n is the number we want to had 
		#l is the level of recursivity
		if l != 0
      #call the API
			#fws = self.get_followers
			fi = self.get_following
			#from the API objects create databases objects   
	    users = User.set_users_from_twitter_users(fi,n)
			self.save!
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
				if !Tweet.find(:first, :conditions => ["twitter_id = ?",twit["id"].to_s])#On vérifie la non existence du twit
				   begin
		    	  Tweet.create(:twitter_id =>twit["id"].to_s, :text => twit["text"], :t_date => twit["created_at"], :user_id => self.id)
			     rescue => e
					   puts "[info]Problem in Tweet.create :"+e.to_s+". It occur in user : "+self.id.to_s
						 if e.to_s == "token_expired"
						   raise e
						 end
						 #to debug puts "[error]"+e.to_s+"\n in user"+self.id.to_s+" with following twit :"+twit.inspect+"\nid :"+twit["id"].to_s+"\ntext :"+twit["text"].to_s+"\ncreated_at :"+twit["created_at"].to_s
					 end
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
