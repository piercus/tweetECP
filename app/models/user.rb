class User < ActiveRecord::Base
  validates_uniqueness_of :screen_name
	has_many :tweets
	has_many :relations
  has_many :friends_to, :foreign_key => "user_to_id", :class_name => "Friendship"
  has_many :friends_from, :foreign_key => "user_from_id", :class_name => "Friendship"
	require 'twitter'
	def get_more_users(l=1)
	  #u is a User in the database
		#l is the level of recursivity
		if l != 0
      #call the API
			fws = self.get_followers
			#from the API objects create databases objects         
	    users = User.set_users_from_twitter_users(fws)
      self.add_followers(users)
	    users.each{|f|
			  f.get_more_users(l-1)
			}
		end
		return users
    end

	def user_timeline(query={})
		# La fonction user_timeline est disponible à partir de l'API REST mais pas à partir de l'API "twitter", j'ai refait la fonction à la main 
		HTTParty.get('http://twitter.com/statuses/user_timeline.json', :query => query)
  end
  
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
	################################################################################################
	#
	# Friendships Getters
	# The output format is like 
	# :weight => 1, // an arbitrary value to classify friendships  
	# :friendType=>"from" or "to" // is self the user who make the friendships or is it the other
	# :friend => Friend Object 
	# :friendType => "follow" or "address"
	################################################################################################
	
  def followers
	  Friendship.findFriends(self,"follow","from")
  end  
  
  def followings
	  Friendship.findFriends(self,"follow","to")
  end  
  def friends
     Friendship.findFriends(self)
  end

	
	def get_followers
		HTTParty.get('http://api.twitter.com/1/statuses/followers.json', :query => {:user_id => twitter_id })
	end	
	
	def get_tweets
		twits = self.user_timeline(:id => self.twitter_id)
		twits.each {|twit|
		  if twit.kind_of?(Hash)#debug because we find tweets like ["request", "/statuses/user_timeline.json?id=46259780"]
			  if !Tweet.find(:first, :conditions => ["twitter_id = ?",twit["id"]])#On vérifie la non existence du twit
		    	  tweet = Tweet.create(:twitter_id =>twit["id"].to_i, :text => twit["text"], :t_date => twit["created_at"], :user_id => self.id)
				  # On récupère les liens depuis les tweets
				  tweet.load_links
			  end
			else
			  puts "Problem with the following twit in get_tweets : \n"+twit.inspect 
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
	  if twitter_user.kind_of?(Hash)
			user = User.find(:first, :conditions => ["screen_name = ? OR twitter_id = ?",twitter_user["screen_name"],twitter_user["id"]])
			if !user
				user = User.create!( :screen_name => twitter_user["screen_name"] ,:name => twitter_user["name"] , :twitter_id => twitter_user["id"], :nfollowers => twitter_user["followers_count"], :nfollowing => twitter_user["friends_count"])
			  # On récupère les tweets par l'API Twitter
			  user.get_tweets
			end

			return user
		else
		  puts "Problem with the following user in set_user_from_twit: \n"+twitter_user.inspect 
		end
	end
	
	def self.set_users_from_twitter_users(twitter_users)
	  # We have a list of twitter users and we want a list of users in database
	  twitter_users.collect{|u|
		  self.set_user_from_twit(u)
		}
	end
	
	def self.set_users_from_name(users)
	  #We have a list of users names and we want a list of users in database
		require 'twitter'
		localUsers = []
		
		users.each{|u|
		  twitter_user = self.get_twitter_user_from_name(u)
			localU = self.set_user_from_twit(twitter_user)
			localUsers.push(localU)
		}
		return localUsers
	end
	def get_note(object,id)
	  if object == "User"
		  u = User.find(id)
		  return Friendship.get_note(self,u)
		end
		if object == "Link"
		  link = Link.find(id)
		  if l.reference
			  link = link.reference
			end
			# 1 is the direct relationnships between the link and the user, 2 is an indirect relationnship through tags or through other users
			weight = {:direct => 0, :by_tags => []}
		  link.referencers.each{|l|
			  #if the link has been twited by the user
			  if l.tweet.user == self
				   weight[:direct] += 10
				end
			}
			tags = u.get_best_tags(30)
			tags.each{|t|
			  if link.tags.include?(t)
				  weight[:by_tags].push({:tag => t, :rare => t.rareness})
				end
			}
			return weight
			
		end	
		if object == "Tag"
		  tag = Tag.find(id)
			weight = 0
		  self.relations.each{|r|
			  if r.tag == tag
				  weight += r.strenght
				end
			}
			return weight
		end	
	end
	def get_best_tags(n,factor = 1)
	  return [] if factor < 0.1
	  taglist = [];
		puts "[debug] in best_tags"
	  self.relations.each{|r|
		  taglist.push({:tag => r.tag, :weight => r.strenght})
		}
		taglist.sort!{|x,y| y[:weight] <=> x[:weight]}
		
		taglist.each{|t| t[:weight] = factor*t[:weight] }
		
		if self.relations.size < n
		  m = self.relations.size
			list = [];
		  self.friends.each{|f|
			  puts f[:friend].inspect
				puts f[:friend].get_best_tags(n-m,factor*1/2).inspect
			  list.push(f[:friend].get_best_tags(n-m,factor*1/2))
			}
			list.flatten!
			list.sort!{|x,y| y[:weight] <=> x[:weight]}
			puts list.inspect + m.inspect + taglist.inspect
			taglist.concat(list)
		end
		return taglist[1,n]
	end
	def last_links(n = 5)
	  ll = [];
		self.tweets.each{|t|
		  ls.push(t.links)
		}
		ls.flatten
		ls[-(n+1)..-1]
	end
  def self.recomand(object, id, n = 20)
	  
		if object == "User"
		  u = User.find(id)
			friends = Friendship.reco(u)
			sortedF = friends.to_a.sort!{|x,y| y[1][:weight] <=> x[1][:weight]}
			
			#if friends.length < n
			  #otherfriends = Friendship.reco(friends[:friend])

			  #continue the algorithm on 2nd degree
			#end

			#format an output
			j = 0;
			out = {};
			while j < n  do
			  out[sortedF[j][0]] = friends[sortedF[j][0]][:weight]
	      j += 1
			end
			return out
		end
		if object == "Link"
		  l = Link.find(id)
			if l.reference
			  l = l.reference
			end
		  url = l.orig_uri
			rel = l.relations
      users = rel.collect{|r|
			  {
				  :user => r.user,
				  :weight => r.user.get_note("Link",l)
				}
			}
			return {:users => users}
		end
		if object == "Tag"
		  tag = Tag.find(id)
		  users = []
			tag.relations.each{|r|
			  users.push({:user => r.user, :weight => r.strengh})
			}
			return {:users => users}
		end
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
			puts list.inspect		
		}
    return list
	end
	

end
