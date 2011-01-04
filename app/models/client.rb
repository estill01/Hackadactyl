class Client < ActiveRecord::Base
  include SessionMethodIncludes

  cattr_accessor :per_page
  @@per_page = 15

  attr_accessor       :password, :previous_password, :password_confirmation
  attr_protected      :hashed_password, :salt

  # For all roles

  validates :first_name,  :length => {:within => 2..50}
  validates :last_name,  :length => {:within => 2..50}
  validates :email,
    :uniqueness => {:message => "already has an account associated with it.", :allow_nil => true},
    :format => {:with => STANDARD_EMAIL_REGEX, :message => "is an invalid address"}

  # validate anytime form params include :password or :email_confirmation
  # i.e. if you send :password, you must send :previous_password
  # You can update :email w/o it as long as :email_confirmation is nil
  validates :previous_password, :auto_password => true, :on => :update

  default_scope :order => "clients.last_name ASC, clients.first_name ASC"

  before_create :create_account_token
  before_update :update_hashed_password
  after_save :sanitize_object


  def create_account_token
    self.account_token = Client.create_token(self.full_name)
  end
  
  def update_hashed_password
    if !self.password.blank?
      self.salt = self.class.make_salt(self.username) if self.salt.blank?
      self.hashed_password = self.class.hash_with_salt(self.password, self.salt)
    end
  end

  def sanitize_object
    self.password = nil
    self.password_confirmation = nil
  end

  def enabled?
    return enabled ? true : false
  end

  def full_name
    return "#{self.first_name} #{self.last_name}"
  end

  def self.authenticate(username="", password="")
    user = self.find_by_username(username)
    return (user && user.is_authenticated?(password)) ? user : false
  end

  def is_authenticated?(password="")
    return (self.hashed_password == self.class.hash_with_salt(password, self.salt))
  end

  def try_to_reset_password( new_password, reconfirm_password)
    if new_password != reconfirm_password
      errors[:base] << "The two new password fields do not match. Please try again."
    elsif new_password.blank?
      errors[:base] << "Your password cannot be left blank."
    elsif new_password.size < 6 || new_password.size > 25
      errors[:base] << "Your must be between 6 and 25 characters"
    end
    if errors.count == 0 && self.update_attributes!(:password => new_password, :password_confirmation => new_password)
      return true
    else
      return false
    end
  end

  def try_to_email_password( password='*encrypted*' )
    if self.email.blank?
      return false
    else
      email_new_password(password)
    end
  end

  def try_to_email_reset_token
    self.update_attributes(:reset_password_token => self.class.create_token(self.username))
    email_reset_token(self)
  end

  def self.make_salt(string="")
    Digest::SHA1.hexdigest("Use #{string} and #{Time.now}")
  end

  def self.hash_with_salt(password="", salt="")
    Digest::SHA1.hexdigest("Put #{salt} on the #{password}")
  end

  def self.create_token(string="")
    Digest::SHA1.hexdigest("Take their name #{string} and #{Time.now}")
  end

  def send_welcome_email
    PostOffice.delay.welcome_email(self)
  end
  
end
