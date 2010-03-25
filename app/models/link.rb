class Link < ActiveRecord::Base
	belongs_to :tweet
  	has_many :tags
		belongs_to :reference, :class_name => 'Link', :foreign_key => 'reference_id'
		has_many :referencers,  :class_name => 'Link', :foreign_key => 'reference_id'
	  validates_format_of :url, :with => /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$/ix, :on => :create
    has_and_belongs_to_many :relations
		validates_uniqueness_of :tweet_id
		
		
		###########################
		#
		#       A. Class Methods
		#
		###########################

		#  Generalization


	  def self.get_references
		  self.all.each{|l|
			  l.get_reference
			}
		end
		
		#recommend the last links in the database
	  def self.reco(n)
		 recos = []
		 self.all{|l|
		   if !l.original.nil? && !l.description.nil?
			   recos.push([l.original,l.description])
			 end
			 recos = recos.uniq
			 if recos.size > n
			   return recos
			 end
		 }
		 return recos
		end
		
    def self.get_delicious_tags
		  puts "[info]Try to get Delicious Tags of all the links in database"
		  #get all delicious tags
			count = 0
			self.all.each{|l|
				l.get_delicious_tags
			}
			return count
		end
		
    def self.get_original_links
		  puts "[info]Try to get Original Links all the links in the database"
		  #get all the original links
			count = 0
			self.all.each{|l|		  
				l.get_original_link if l.original.blank?
			}
			return count
		end		
		
		# clean_up
		def self.clean_up
      self.get_reference
			
		end
		
		
		###########################
		#
		#       A. Instance Method
		#
		###########################		
		
		
		
		
		
	  def tags
		  return self.relations.collect{|r| r.tag }.uniq
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
		
		#############################################
		# Function to get original link from a mini link
		#
		# Links are often not available and it's a hazardous process with some loss in the database
		# We make specific coding for most common problems,
		#Errors are logs in the standard output (server console) 
		# That's why we make a lot of rescue loop, but this loop should be implemented in a proper way
		
  	def get_original_link
	    # dans le cas ou le lien est raccourci (if taille du lien < 30 caractères), récupèrer le lien original
	
	    #open-uri : une librairie pour récupérer une page web depuis un lien  
      raise "no url in the object" if self.url.nil?
      return false if self.url.nil?
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
							return false
						end
					rescue => e
						if self.url.slice(-1..-1) == "."
						   		self.url = self.url.slice(0..-2)
									self.original = self.parse_mini_url(self.url)
									self.save
						else
						  puts "[info]Problem with to get original link : "+e.to_s+"\nWith the link (id :"+self.inspect+ ") see the logs for more informations"
							logger.info self.inspect
							return false
						end
						return false
				  end  
					#display a message when it's nil
					if self.original.nil?
						puts "[Error] while loading the link" + self.url
					end
			else
			  orig_uri = self.url
				self.save
			end
			return self.original
		end	
		
		def get_reference
      self.delete if self.url.nil?
		  self.get_original_link if self.original.blank?
			link = Link.find(:first,:conditions => ["original = ?",self.original])
			if link.id != self.id
				  self.reference = link
			end
      self.save!
		  return self.reference
  	end
  	
		def get_delicious_tags
		  return self.tags if self.delicioused
			# récupèrer les tags associés aux lien "original" auprès de delicious
	
			require "rexml/document"
			require "lib/delicious/api"
			self.delicioused = true		
			self.save!
			imported_tags = []
		
			# Consumer Key & Shared Secret provided by Yahoo!

			key = "dj0yJmk9a3owem9BVWlxbWhMJmQ9WVdrOVdERTRTRzFITjJzbWNHbzlNVFkzTmpjMU5ERTJNZy0tJnM9Y29uc3VtZXJzZWNyZXQmeD01Ng--"
			secret ="d5eca4f03b486b19bf168c4705a58eb7dd0692d8"
			# App ID : X18HmG7k
	
			api = Delicious::API.new(key,secret)
			begin
			  response = api.suggest!(original)
			rescue => e
			  if e.to_s == "token_expired"
          puts "[error] You must delete the files access_token.yml and requset_token.yml" 
					raise e
				end
			end
			resp = response.body
			
			doc = REXML::Document.new(resp)
			doc.elements.each("*/recommended"){|tag| imported_tags.push(tag.text)}
			doc.elements.each("*/popular"){|tag| imported_tags.push(tag.text)}
			# Ici on doit ajouter une fonction qui créé les tags dans la base de données
			# en vérifiant qu'ils existent pas encore et qui lie ce lien à ces tags
			puts "[info]Take Tags from delicious, :"+imported_tags.inspect
			Relation.build(imported_tags, self,5)			


			return imported_tags
  	end
		def get_tags
		  if !self.delicioused
			  tags = self.get_delicious_tags
				if tags.size == 0
				  self.get_tags_from_meta
				end
			else
			  self.get_tags_from_meta
			end
		end
  	def get_tags_from_meta
		  return self.tags if !self.delicioused
			require 'nokogiri'
      require 'open-uri'
			begin
			  doc = Nokogiri::HTML(open(self.original))
			rescue
			  puts "[error] with the link "+self.inspect+"\nReturn no tags" 
		    return []
		  end
			balise = doc.xpath('//meta[@name=\'keywords\']')[0]
			return [] if balise.nil? 
			text = balise.attributes["content"].content
			tags = text.split(',').collect{|s| s.strip.downcase}
			Relation.build(tags, self,1)	
			return tags
		end	
  	
  	def get_description_from_meta
			require 'nokogiri'
      require 'open-uri'
			begin
			  doc = Nokogiri::HTML(open(self.original))
			rescue
			  puts "[error] with the link "+self.inspect+"\nReturn no tags" 
		    return []
		  end
			balise = doc.xpath('//meta[@name=\'description\']')[0]
			return [] if balise.nil? 
			text = balise.attributes["content"].content
			self.description = text
			self.save!
		end	
				
	end
