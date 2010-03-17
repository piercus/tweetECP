class WelcomeController < ApplicationController
  protect_from_forgery :only => [:create, :update, :destroy] 
	before_filter :set_class_object :except => :index
	
	#Cette action va être lu avant les autres actions et va permettre de faire des actions communes à toutes les action s(ici il s'agit de savoir si on fait du Tag ou du User)
	def set_class_object
	   if params[:type]=="user"
		  classType = User
		elsif params[:type]=="tag"
		  classType = Tag
		else
		  raise "Not a valid type"
			return false
		end
	end
  def index	       
	  url = url_for(:controller => "welcome", :action => "search", :type => "valueuser", :id_user => "scobleizer")
  
	 @input = {"tags" => {"web" => [10,""], "music" => [20,""], "politics" => [20,""], "sports" => [20,""]}, "users" => {"loic" => [20,""], "scobleizer" => [20,url], "jalove" => [20,""], "thaven" => [20,""]} }.to_json

  end
  def autocomplete
    return false if !params[:query]
		like = params[:query].concat("%")
		object = classType.find_by_dname_like(like).collect{|u| u.dname}
		render :text => users.to_json
	end    
  def search
		if params[:id].blank?
        flash[:notice] = "Not a valid "+params[:type]
        redirect_to :action => "index"
				return false
		end
    @object = classType.find_by_dname(params[:id])	
  	if @object.nil?
        flash[:notice] = "Not a valid "+params[:type]
        redirect_to :action => "index"
				return false
		end
		@last_tweets = @object.tweets[-5..-1]
    @input = {
 		   "users" => @object.get_best_users(10,1),
		   "tags" => @object.get_best_tags(10,1,)
		}    
  end      
	
end
