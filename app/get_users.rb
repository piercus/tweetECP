class GetUsers < ActiveRecord::Base
  
  #test
  require 'twitter'
  # users = ['loic']

  def self.get_more_users(u,l =1 )
	  #u is a User in the database
		#l is the level of recursivity
		if l != 0
      #call the API
			fws = u.get_followers
			
			#from the API objects create databases objects         
	    users = User.set_users_from_twitter_users(fws)
			u.add_followers(users)
	    users.each{|f|
			  self.get_more_users(f,l-1)
			}
		end
		return users
  end
  
  users = get_more_users( User.set_user('scobleizer'))
    
  # User.set_users(users)


  def self.get_more_users(u)

end


# FONCTION QUI VA UN CRAN PLUS LOIN
# Voir plus haut, avec le "l" de la recusrivity on a tt mis dans la même fonction !!


#  def get_more_users(user)                # à partir d'un user originel
#    users = []                             
#    fws = user.followers                  # on récupère ses followers
#    fws_fws = []
#    fws.each{|u|                          # et pour chaqu'un d'eux
#      fws_fws = fws_fws + u.followers     # on récupère ses propres followers, qu'on rajoute dans fwd_fwd
#    }
#    users = user + fws_fws                # 'users' contient donc un user, ses fwrs ainsi que les fwrs de ses fwrs.
#    return users
#  end

