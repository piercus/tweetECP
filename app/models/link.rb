class Link < ActiveRecord::Base
  belongs_to :tweet
  has_many :tags
	validates_format_of :url, :with => /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$/ix, :on => :create

  def get_original_link
    #open-uri : une librairie pour récupérer une page web depuis un lien  
    require 'open-uri'
    # dans le cas ou le lien est raccourci, récupère le lien original
    # if taille du lien < 20 caractères
    # P: Je ne sais pas trop si 20 c'est pas trop court, j'ai mis 30 au cas ou
  
    if self.url.size<30
      # Guillaume:    le decompresser en le mettant dans un navigateur et en récupérant l'url sur laquelle il pointe
      # Pierre : J'ai juste utililser open-uri, normalement ca fonctionne simplement comme ca (pas besoin de passer par un navigateur) il faut tt de même tester sur tous les services de mini-url
      page = open self.url 
      self.url = page.base_uri.to_s
      self.save!
    end
    return self.url
  end

  def delicious_tags

    require "rexml/document"
    require "lib/delicious/api"
    
    imported_tags = []
    
    secret = "d8882abeadb73a8d5a17800a4ff948580132d7f9"
    key ="dj0yJmk9aTVMYU90Y0lYY2F1JmQ9WVdrOVFucHlaV1JPTXpnbWNHbzlNVGt3TkRBME1EQTJNZy0tJnM9Y29uc3VtZXJzZWNyZXQmeD0wYg--"
 
    api = Delicious::API.new(key,secret)
    response = api.suggest!(url)
    resp = response.body
    puts resp.inspect
    doc = REXML::Document.new(resp)
    doc.elements.each("*/recommended"){|tag| imported_tags.push(tag.text)}
    doc.elements.each("*/popular"){|tag| imported_tags.push(tag.text)}
    #Ici on doit ajouter une fonction qui créé les tags dans la base de données en vérifiant qu'ils existent pas encore et qui lie ce lien à ces tags
    return imported_tags
  end
end
