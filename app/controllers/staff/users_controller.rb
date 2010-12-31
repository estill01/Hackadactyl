class Staff::UsersController < ApplicationController

  layout 'staff'

  before_filter :confirm_staff_logged_in

  def index
    @users = User.paginate(:page => params[:page])
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
    @password_idea = get_nice_password
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = "Administrator was successfully created."
      redirect_to staff_users_path
    else
      render('new')
    end
  end

  def edit
    @user = User.find(params[:id])
    @password_idea = get_nice_password
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:notice] = "Administrator was successfully updated."
      redirect_to staff_users_path
    else
      render('edit')
    end
  end

  def delete
    @user = User.find(params[:id])
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:notice] = "Administrator was successfully deleted."
    redirect_to staff_users_path
  end

end
