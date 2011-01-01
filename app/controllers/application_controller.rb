class ApplicationController < ActionController::Base
  include SessionMethods
  layout 'staff'

  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  before_filter :correct_accept_headers
  
  def correct_accept_headers
    # Used to fix acceptence header in ie and safari.
    # NB remember sort needs to modify so keep it sort!
    request.accepts.sort! { |x, y| y.to_s == "text/javascript" ? 1 : -1 } if request.xhr?
  end

  def order_using_params
    params[:order] ? "#{params[:order]} #{params[:dir]}" : nil
  end

  def render_404
    render :file => Rails.root.to_s + "/public/404.html", :status => 404 and return
  end

  def render_500
    render :file => Rails.root.to_s + "/public/500.html", :status => 500 and return
  end

  def get_nice_password
    return NicePassword.new(:length => 12, :words => 2, :digits => 2)
  end

  protected

    def confirm_staff_logged_in
      unless session[:id] && session[:id].to_i > 0 && session[:class] == "User"
        session[:desired_url] = url_for(params)
        flash[:notice] = "Please log in."
        redirect_to(staff_login_path) and return false
      end
      return true
    end

    def confirm_not_logged_in
      if session[:id]
        flash[:notice] = "You are already logged in"
        redirect_to staff_menu_path
      end
      return true
    end

    def redirect_to_desired_url(fallback_url={:action => 'index'})
      if session[:desired_url]
        desired_url = session[:desired_url]
        session[:desired_url] = nil
        redirect_to(desired_url)
      else
        redirect_to(fallback_url)
      end
    end

end
