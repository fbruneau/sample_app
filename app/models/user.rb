#encoding = UTF-8
# == Schema Information
#
# Table name: users
#
#  id         :integer         not null, primary key
#  nom        :string(255)
#  email      :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class User < ActiveRecord::Base
  attr_accessible :email, :nom,:taille,:poidactu,:poidideal, :imc,:password, :password_confirmation, :cv, :delete_CV, :dob
	attr_accessor :password

	has_attached_file :cv,
  :path => ':rails_root/app/assets/documents/:attachment/:id/:style/:basename.:content_type_extension',
  :url => '/cv?id=:id'

	email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	validates :nom, :presence => true, :length   => { :maximum => 50 }
	validates :email, :presence => true, :format => { :with => email_regex }, :uniqueness => { :case_sensitive => false }
	validates :password, :presence     => true,
                       :confirmation => true,
                       :length       => { :within => 6..40 }
	validates :dob, :presence => true
	validates :taille, :presence => true, :numericality => {:greater_than_or_equal_to => 0.1,  :less_than_or_equal_to => 3}
	validates :poidactu, :presence => true, :numericality => {:greater_than_or_equal_to => 1,  :less_than_or_equal_to => 700}
	validates :poidideal, :presence => true, :numericality => {:greater_than_or_equal_to => 1,  :less_than_or_equal_to => 700, :less_than_or_equal_to => :poidactu}
	validates_attachment_content_type :cv, :content_type => [ 'application/pdf' ]
	before_save :encrypt_password
	before_save :init_mensuration
	#before_save :check_CV
	before_save :calc_imc
	before_save :destroyCV?

	def has_password?(password_soumis)
	  encrypted_password == encrypt(password_soumis)
	end

	def self.authenticate(email, submitted_password)
	  user = find_by_email(email)
	  return nil  if user.nil?
	  return user if user.has_password?(submitted_password)
	end
	
	def self.authenticate_with_salt(id, cookie_salt)
    user = find_by_id(id)
    (user && user.salt == cookie_salt) ? user : nil
  end

	def check_CV
		if( self.cv_file_name == "" )
			self.cv = nil
		end
	end

	def delete_CV
    @delete_CV ||= "0"
  end

  def delete_CV=(value)
    @delete_CV = value
  end

	private

    def encrypt_password
      self.salt = make_salt if new_record?
      self.encrypted_password = encrypt(password)
    end
		
		def init_mensuration
			if (self.taille == "") 
				self.taille = 0 
			end
			if (self.poidactu == "") 
				self.poidactu = 0 
			end
			if (self.poidideal == "") 
				self.poidideal = 0 
			end
		end
	
		def calc_imc
			if (self.poidactu.nil? || self.poidideal.nil? || self.taille.nil? )
				#Si l'utilisateur n'a pas saisi toutes les données, il n'y a pas d'imc calculable
				self.imc ="" 
			else
				self.imc = self.poidactu / (self.taille * self.taille)
				self.imc = ((self.imc*100).round.to_f)/100
			end		
		end

    def encrypt(string)
      secure_hash("#{salt}--#{string}")
    end

    def make_salt
      secure_hash("#{Time.now.utc}--#{password}")
    end

    def secure_hash(string)
      Digest::SHA2.hexdigest(string)
    end

		def destroyCV?
   		self.cv.clear if @delete_CV == "1"
  	end

end
