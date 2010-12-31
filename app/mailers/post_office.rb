class PostOffice < ActionMailer::Base
  default :from => SYSTEM_EMAIL
  
  def email_new_staff_password(user, password)
    @user = user
    @password = password
    mail(
      :to => user.email,
      :subject => "Password Reset",
      :headers  => {"Reply-to" => "#{user.email}"}
    )
  end

end
