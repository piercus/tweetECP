class Tag < ActiveRecord::Base
  belongs_to :link
  has_many :links
  
end
