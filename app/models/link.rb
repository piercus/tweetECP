class Link < ActiveRecord::Base
	belongs_to :tweet
  	has_many :tags
		belongs_to :reference, :class_name => 'Link', :foreign_key => 'reference_id'
		has_many :referencers,  :class_name => 'Link', :foreign_key => 'reference_id'
	  validates_format_of :url, :with => /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$/ix, :on => :create
    has_and_belongs_to_many :relations
		validates_uniqueness_of :tweet_id
		
    def self.get_delicious_tags
		  puts "[info]Try to get Delicious Tags of all the links in database"
		  #get all the original links
			count = 0
			self.all.each{|l|
				l.get_original_link if l.original.nil?		  
			}
			return count
		end

    def self.get_original_links
		  puts "[info]Try to get Original Links all the links in the database"
		  #get all the original links
			count = 0
			self.all.each{|l|
			  
				l.get_original_link if l.original.nil?
				
			  
			}
			return count
		end
		def parse_mini_url(url)#put this in a library
			require 'open-uri'
		  page = open(self.url, "User-Agent" => "Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.2.2pre) Gecko/20100130 Ubuntu/8.10 (intrepid) Namoroka/3.6.2pre")
			orig_uri = page.base_uri.to_s
			if orig_uri[0..13] == "http://nxy.in/"
						result = HTTParty.get('http://nxy.in/api_1_1_0/expand.aspx', :query => {:url => orig_uri, :type => "xml" })
						orig_uri =  result["LongUrl"]
			end
			return orig_uri
		end
  	def get_original_link
	    # dans le cas ou le lien est raccourci (if taille du lien < 30 caractères), récupèrer le lien original
	
	    #open-uri : une librairie pour récupérer une page web depuis un lien  
      raise "no url in the object" if self.url.nil?
	    require "timeout"
      require 'twitter' #we use HTTParty in the hack for nxy.in
			
			orig_uri = ""
	    if self.url.size<30
				  begin  
					  begin
					    # Hack for rescue the timeout error, see http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/240509
					    Timeout::timeout(10) do |timeout_length|				
							  self.original = self.parse_mini_url(self.url)
							  self.save!
							end
						rescue Timeout::Error
              puts "[Error]Timeout Error : "+self.inspect
							self.url = nil
							return false
						end
					rescue => e
						if self.url.slice(-1..-1) == "."
						   		self.url = self.url.slice(0..-2)
									self.original = self.parse_mini_url(self.url)
									self.save
						else
						  puts "[Error]Problem with the link (id :"+self.id+ ") see the logs for more informations"
							logger.info self.inspect
						end
						return false
				  end  
					#display a message when it's nil
					if self.original.nil?
						puts "Error while loading the link" + self.url
					end
			else
			  orig_uri = self.url
			end
			return self.original
		end	
		def self.get_references
		  self.all.each{|l|
			  l.get_reference
			}
		end
		def get_reference
		  self.get_original_link if self.original.blank?
			link = Link.find(:first,:conditions => ["original = ?",self.original])
			if !link.nil?
				  self.reference = link
			end
      self.save!
		  return self.reference
  	end
  	def get_delicious_tags
    	# récupèrer les tags associés aux lien "original" auprès de delicious
		
    	require "rexml/document"
    	require "lib/delicious/api"
    	
    	imported_tags = []
    	
    	# Consumer Key & Shared Secret provided by Yahoo!
    	secret = "d8882abeadb73a8d5a17800a4ff948580132d7f9"
    	key ="dj0yJmk9aTVMYU90Y0lYY2F1JmQ9WVdrOVFucHlaV1JPTXpnbWNHbzlNVGt3TkRBME1EQTJNZy0tJnM9Y29uc3VtZXJzZWNyZXQmeD0wYg--"
 		
    	api = Delicious::API.new(key,secret)
    	response = api.suggest!(original)
    	resp = response.body
    	
    	doc = REXML::Document.new(resp)
    	doc.elements.each("*/recommended"){|tag| imported_tags.push(tag.text)}
    	doc.elements.each("*/popular"){|tag| imported_tags.push(tag.text)}
    	# Ici on doit ajouter une fonction qui créé les tags dans la base de données
    	# en vérifiant qu'ils existent pas encore et qui lie ce lien à ces tags
   
   		Relation.build(imported_tags, self)			
   
       	return imported_tags
  		end
  		
  		
				
	end
