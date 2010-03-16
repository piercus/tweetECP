class WelcomeController < ApplicationController
  
  def index
  end
      
  def search
    
    @input = {"tags" => {
			"web" => 10, 
			"music" => 20, 
			"politics" => 30, 
			"sports" => 40
		}, 
		"users" => {
			"loic" => 10, 
			"scobleizer" => 20, 
			"jalove" => 30, 
			"thaven" => 40} 
		}.to_json
    id = 
    reco = { 
		   "users" => User.recomand(params[:type],params[:id]),
		   "tags" => Tag.recomand(params[:type],params[:id])
		}
    if params[:type]=="User"
		  
		  User.recommand
      if params[:id].blank?
        flash[:notice] = "User not valid"
        redirect_to :action => "index"
      else
        @user = User.find(:first, :conditions => ["screen_name = ?", params[:id]])
        @last_tweets = Tweet.find(:all,:conditions => ["user_id = ?", @user.id])[-3..-1]
      end  
    elsif params[:type]=="Tag"
      if params[:id].blank?
        flash[:notice] = "Tag not valid"
        redirect_to :action => "index"
      else
        @tag = Tag.find(:first, :conditions => ["word = ?", params[:id]])
        redirect_to :action => "index"
      end
    end
    
  end      
    
end
