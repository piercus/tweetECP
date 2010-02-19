class Tweet < ActiveRecord::Base
  validates_uniqueness_of :twitter_id
	has_many :links
	belongs_to :user
	
	def load_links
   # créer un objet Link pour chaque URL du tweet
          require 'uri' 
	  urls = URI.extract(text)
          urls.each{|urlArray|
		  Link.create(:url => urlArray, :tweet_id => self.id, :post_date => self.t_date)
		}
	end
	
end
