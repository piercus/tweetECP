class WelcomeController < ApplicationController
  
  def index
  end
  
  def hello
    @users = User.find(:all)
  end
  
  def search
    if params[:id_user]
      @user = User.find(:first, :conditions => ["screen_name = ?", params[:id_user]])
    else
      @user = User.find(:first, :conditions => ["screen_name = ?", params["user"]["username"]])
    end
    @tweet0 = Tweet.find(:all,:conditions => ["user_id = ?", @user.id])[0]
    @tweet1 = Tweet.find(:all,:conditions => ["user_id = ?", @user.id])[1]
    @tweet2 = Tweet.find(:all,:conditions => ["user_id = ?", @user.id])[2]
    
  end
  
end