module SessionMethodIncludes
  
  
  def remember_token?
     !self.remember_token.blank? &&
       !self.remember_token_expires_at.blank? &&
       Time.now.utc < self.remember_token_expires_at.utc
   end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = self.class.create_token
    save(:validate => false)
  end

  # refresh token (keeping same expires_at) if it exists
  def refresh_token
    if remember_token?
      self.remember_token = self.class.create_token
      save(:validate => false)
    end
  end

  # Deletes the server-side record of the authentication token.  The
  # client-side (browser cookie) and server-side (this remember_token) must
  # always be deleted together.
  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(:validate => false)
  end

end
