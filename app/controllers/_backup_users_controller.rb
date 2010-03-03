class UsersController < ApplicationController
  
  def index
    @users = User.find(:all, :conditions => ['name LIKE ?', "%#{params[:search]}%"])
  end
  
end