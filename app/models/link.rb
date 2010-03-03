class Link < ActiveRecord::Base
	belongs_to :tweet
  	has_many :tags
		belongs_to :reference, :class_name => 'Link', :foreign_key => 'reference_id'
		has_many :referencers,  :class_name => 'Link', :foreign_key => 'reference_id'
	validates_format_of :url, :with => /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$/ix, :on => :create

  	def get_original_link
	    # dans le cas ou le lien est raccourci (if taille du lien < 30 caractères), récupèrer le lien original
	
	    #open-uri : une librairie pour récupérer une page web depuis un lien  
	    require 'open-uri'
	  
	    if self.url.size<30
			  page = open self.url
			  orig_uri = page.base_uri.to_s
				link = Link.find(:first,:conditions => ["original = ?",orig_uri])
			  if link
				  self.
				self.original
			  self.save!
	    end
		return self.original
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
   
   		Relation.build(importedtags, self)			
   
       	return imported_tags
  		end
  		
  		
				
	end
