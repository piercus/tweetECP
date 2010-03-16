class WelcomeController < ApplicationController
  protect_from_forgery :only => [:create, :update, :destroy] 
  def index	       
	url = url_for(:controller => "welcome", :action => "search", :type => "valueuser", :id_user => "scobleizer")
  
	 @input = {"tags" => {"web" => [10,""], "music" => [20,""], "politics" => [20,""], "sports" => [20,""]}, "users" => {"loic" => [20,""], "scobleizer" => [20,url], "jalove" => [20,""], "thaven" => [20,""]} }.to_json

  end
  def autocomplete
    return false if !params[:query]
		like = params[:query].concat("%")

		users = User.find(:all,:conditions => ["screen_name like ?", like]).collect{|u| u.screen_name}
		render :text => users.to_json
	
	end    
  def search

    
    url = url_for(:controller => "welcome", :action => "search", :type => "valueuser", :id_user => "scobleizer")
    @input = {"tags" => {"web" => [10,""], "music" => [20,""], "politics" => [20,""], "sports" => [20,""]}, "users" => {"loic" => [20,""], "scobleizer" => [20,url], "jalove" => [20,""], "thaven" => [20,""]} }.to_json

    reco = { 
		   "users" => User.recomand(params[:type],params[:id]),
		   "tags" => Tag.recomand(params[:type],params[:id])
		}
    if params[:type]=="user"
		  

      if params[:id].blank?
        flash[:notice] = "User not valid"
        redirect_to :action => "index"
      else

       # @user = User.find(:first, :conditions => ["screen_name = ?", params[:id]])
        @user = User.find(:first, :conditions => ["screen_name = ?", params[:id]])
        @last_tweets = @user.tweets
        #@last_links = Link.find(:all,:conditions => ["user_id = ?", @user.id])[-5..-1]
      end  
    elsif params[:type]=="tag"
      if params[:id].blank?
        flash[:notice] = "Tag not valid"
        redirect_to :action => "index"
      else
        @tag = Tag.find(:first, :conditions => ["word = ?", params[:id]])
      end
    end
    
  end      
    
end
