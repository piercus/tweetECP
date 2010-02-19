class GetUsers < ActiveRecord::Base
  # This script deletes all posts that are over 5 minutes old
  # pour lancer ce script  faire : ruby script/runner app/get_users.rb
  require 'twitter'
#searches all tweets for httparty
#Twitter::Search.new('party').each do |r| 
#  puts r.inspect
#end
  
  twit_user =  Twitter.user('loic')
  if user = User.find(:first, :conditions => ["screen_name = ?",twit_user.screen_name])
  else
	  user = User.create!( :screen_name => twit_user.screen_name ,:name => twit_user.name , :twitter_id => twit_user.id, :nfollowers => twit_user.followers_count, :nfollowing => twit_user.friends_count )
  end
  user.get_tweets #On récupère les tweets par l'api twitter
  user.tweets.each{|tweet| tweet.load_links} #on récupère les liens depuis les tweets
  
end

