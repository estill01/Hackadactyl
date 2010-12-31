class Staff::AccessController < ApplicationController

  layout 'staff'

  before_filter :confirm_staff_logged_in, :only => [:menu, :destroy]

  def index
    menu
  end

  def menu
    # just text
  end

  def new
    @hide_navigation = true
    # display login form
  end

  def create
    logout_keeping_session!
    found_user = User.authenticate(params['username'], params['password'])
    if found_user && found_user.enabled?
      self.current_user = found_user
      handle_remember_cookie!(params[:remember_me] == "1")
      flash[:notice] = "You are now logged in."
      redirect_to(staff_menu_path)
    elsif found_user && !found_user.enabled?
      @hide_navigation = true
      flash[:error] = "Your account has been disabled."
      render('new')
    else
      @hide_navigation = true
      flash[:error]= "Username/password combination not found. Please try again."
      render('new')
    end
  end

  def destroy
    logout_keeping_session!
    flash[:notice] = "You are now logged out."
    redirect_to(staff_login_path)
  end


  #--- Password Methods ---

  def forgot_password
    @hide_navigation = true
    # display form
  end

  def send_new_password
    @user = User.where(:username => params[:username], :enabled => true).first
    if @user
      @user.delay.try_to_email_password(get_nice_password)
      flash[:notice] = "New password sent to account's designated email"
      redirect_to staff_login_path
    else
      @hide_navigation = true
      flash[:notice] = "Username not found"
      render("forgot_password")
    end
  end

  def get_password_idea
    render(:text => get_nice_password)
  end

end
