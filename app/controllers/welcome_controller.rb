class WelcomeController < ApplicationController
  
  def index
  end
      
  def search
  
    @input = {"tags" => {"web" => 10, "music" => 20, "politics" => 30, "sports" => 40}, "users" => {"loic" => 10, "scobleizer" => 20, "jalove" => 30, "thaven" => 40} }.to_json
    
    
    if params[:type]=="valueuser"
      if params[:id_user].blank?
        flash[:notice] = "User not valid"
        redirect_to :action => "index"
      else
        @user = User.find(:first, :conditions => ["screen_name = ?", params[:id_user]])
        @last_tweets = Tweet.find(:all,:conditions => ["user_id = ?", @user.id])[-3..-1]
      end  
    elsif params[:type]=="valuetag"
      if params[:id_tag].blank?
        flash[:notice] = "Tag not valid"
        redirect_to :action => "index"
      else
        @tag = Tag.find(:first, :conditions => ["word = ?", params[:id_tag]])
        redirect_to :action => "index"
      end
    end
    
  end      
    
end