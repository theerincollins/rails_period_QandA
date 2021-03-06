class User < ActiveRecord::Base
  attr_accessor :password
  validates_presence_of :username
  validates_presence_of :email
  validates_presence_of :password
  validates_confirmation_of :password
  validates_length_of :username, :maximum => 15

  before_save :encrypt_password
  after_create :send_welcome_message

  has_many :questions
  has_many :answers

  def encrypt_password
    self.password_salt = BCrypt::Engine.generate_salt
    self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
  end

  def self.authenticate(username, password)
    user = User.where(username: username).first
    if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
      user
    else
      nil
    end
  end

  def send_welcome_message
    UserMailer.signup_confirmation(self).deliver
  end

end
