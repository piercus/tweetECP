class GetUsers < ActiveRecord::Base
  
  require 'twitter'
  # users = ['loic']

  def self.get_more_users(user)
    u = Twitter.user(user)
    puts u.inspect            # Ok, ca me renvoie les infos relatives au user que j'indique dans l'appel a la fct plus bas
    fws = []
    fws = u.followers         # LE PROBLEME EST ICI, je ne sais pas si u.followers me renvoie qqchose et quel est son format
    puts fws.inspect          # => 'nil'
    users = [user]
    users << fws              # je rajoute les followers au user initial. 
    return users
  end
  
  users = get_more_users('scobleizer')
    
  # User.set_users(users)

end


# FONCTION QUI VA UN CRAN PLUS LOIN

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

