class Tag < ActiveRecord::Base
  	belongs_to :link
  	has_many :links
  	has_many :relations
  
  	def weight
  		w = 0
  		relations.each {|relation|
  			w =+ relations.length
  		}	
		return w
	end
		
end

