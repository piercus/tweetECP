class WelcomeController < ApplicationController
  
  def index
  end
  
  def search
    if params[:id]
      @user = User.find(:first, :conditions => ["screen_name = ?", params[:id]])
    else
      @user = User.find(:first, :conditions => ["screen_name = ?", params["user"]["username"]]) 
    end 
  end
  
  def hello
    @users = User.find(:all) 
  end
  
end