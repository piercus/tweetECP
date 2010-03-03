class GetUsers < ActiveRecord::Base
  
  require 'twitter'

  
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

