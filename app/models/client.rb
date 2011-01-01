class Client < ActiveRecord::Base
  include SessionMethodIncludes

  cattr_accessor :per_page
  @@per_page = 15

  attr_accessor       :password, :previous_password
  attr_protected      :hashed_password, :salt

  # For all roles

  validates :first_name,  :length => {:within => 2..50}
  validates :last_name,  :length => {:within => 2..50}
  validates :username,
    :length => {:within => 8..25},
    :format => {:with => /^([a-z0-9_]+)$/i},
    :uniqueness => { :case_sensitive => false, :message => "already exists. Please try again." }
  validates :password,
    :length => {:within => 8..25},
    :confirmation => true,
    :on => :create

  validates :email,
    :uniqueness => {:message => "already has an account associated with it."},
    :format => {:with => STANDARD_EMAIL_REGEX, :message => "is an invalid address"},
    :confirmation => {:if => :email_changed? }

  validates :email_confirmation, :presence => true,  :on => :update, :if => :email_changed?
  # validate anytime form params include :password or :email_confirmation
  # i.e. if you send :password, you must send :previous_password
  # You can update :email w/o it as long as :email_confirmation is nil
  validates :previous_password, :auto_password => true, :on => :update

  default_scope :order => "users.last_name ASC, users.first_name ASC"

  before_create :create_hashed_password
  before_update :update_hashed_password
  after_save :sanitize_object


  def create_hashed_password
    self.salt = self.class.make_salt(self.username)
    self.hashed_password = self.class.hash_with_salt(self.password, self.salt)
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
    self.email_confirmation = nil
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

  private #---------


end
