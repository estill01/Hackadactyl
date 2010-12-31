module SessionMethods

  protected

    def logged_in?
      unless current_user
        return false
      else
        return true
      end
    end

    def current_user
      @current_user ||= (login_from_session || login_from_cookie) unless @current_user == false
    end

    def current_user=(new_user)
      session[:id] = new_user ? new_user.id : nil
      session[:username] = new_user ? new_user.username : nil
      session[:class] = new_user ? new_user.class.name : nil
      @current_user = new_user || false
    end

    def login_from_session
      user =  session[:class].constantize.find_by_id(session[:id]) if session[:id]
      if user
        if user.enabled
          self.current_user = user
        else
          logout_keeping_session!
        end
      end
    end

    def login_from_cookie
      user =  cookies[:class].constantize.find_by_remember_token(cookies[:auth_token]) if (cookies[:auth_token] && cookies[:class])
      if user && user.remember_token?
        if user.enabled
          self.current_user = user
          handle_remember_cookie! false # freshen cookie token (keeping date)
          return self.current_user
        else
          logout_keeping_session!
        end
      end
    end

    # The session should only be reset at the tail end of a form POST --
    # otherwise the request forgery protection fails. It's only really necessary
    # when you cross quarantine (logged-out to logged-in).
    def logout_killing_session!
      logout_keeping_session!
      reset_session
    end

    def logout_keeping_session!
      # Kill server-side auth cookie
      @current_user.forget_me if @current_user.is_a? User
      @current_user = false
      kill_remember_cookie!     # Kill client-side auth cookie
      session[:id] = nil
      session[:username] = nil
      session[:class] = nil
      # explicitly kill any other session variables you set
    end


    def kill_remember_cookie!
      cookies.delete :auth_token
      cookies.delete :class
    end

    def valid_remember_cookie?
      return nil unless @current_user
      (@current_user.remember_token?) &&
        (cookies[:auth_token] == @current_user.remember_token)
    end

    def send_remember_cookie!
      cookies[:auth_token] = {
        :value   => @current_user.remember_token,
      :expires => @current_user.remember_token_expires_at }
      cookies[:class] = @current_user.class.name
    end

    # Refresh the cookie auth token if it exists, create it otherwise
    def handle_remember_cookie!(new_cookie_flag)
      return unless  @current_user
      case
        when valid_remember_cookie? then  @current_user.refresh_token # keeping same expiry date
        when new_cookie_flag        then  @current_user.remember_me
        else                              @current_user.forget_me
      end
      send_remember_cookie!
    end

end
