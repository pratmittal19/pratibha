class UserLogin < ActiveRecord::Base
  require 'bcrypt'
  attr_accessor :password
  EMAIL_REGEX = /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\Z/i
  validates :email, :presence => true, :uniqueness => true, :format => EMAIL_REGEX
  validates :password, :confirmation => true #password_confirmation attr
  validates_length_of :password, :in => 6..20, :on => :create
  before_save :encrypt_password
  after_save :clear_password
  before_create :set_confirmation_token
 	def encrypt_password
	  if password.present?
	    self.salt = BCrypt::Engine.generate_salt
	    self.encrypted_password= BCrypt::Engine.hash_secret(password, salt)
	  end
	end
	def clear_password
	  self.password = nil
	end

	# private
	def validate_email
	   self.email_confirmed = true
	   self.confirm_token = nil
	end

	def set_confirmation_token
      if self.confirm_token.blank?
          self.confirm_token = SecureRandom.urlsafe_base64.to_s
      end
    end

    def self.authenticate(email="", login_password="")
    	if  EMAIL_REGEX.match(email)    
			user = UserLogin.find_by_email(email)
		end
		if user && (!user.email_confirmed.nil? || user.email_confirmed == true)&& user.match_password(login_password)
			return user
		else
			return false
		end
	end  

	def match_password(login_password="")
		encrypted_password == BCrypt::Engine.hash_secret(login_password, salt)
	end
end
