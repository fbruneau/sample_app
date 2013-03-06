#encoding : UTF-8
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

require 'spec_helper'
#User********************************************************************************************************
describe User do

  before(:each) do
    @attr = { 
			:nom => "Example User", 
			:email => "user@example.com",
			:password => "foobar",
      :password_confirmation => "foobar",
			:poidactu => "60",
			:poidideal => "59",
			:taille => "1.7"
    }
  end

  it "devrait créer une nouvelle instance dotée des attributs valides" do
    User.create!(@attr)
  end

  it "devrait exiger un nom" do
    bad_guy = User.new(@attr.merge(:nom => ""))
    bad_guy.should_not be_valid
  end

	it "exige une adresse email" do
    no_email_user = User.new(@attr.merge(:email => ""))
    no_email_user.should_not be_valid
  end

	it "devrait rejeter les noms trop longs" do
    long_nom = "a" * 51
    long_nom_user = User.new(@attr.merge(:nom => long_nom))
    long_nom_user.should_not be_valid
  end

	it "devrait accepter une adresse email valide" do
    adresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
    adresses.each do |address|
      valid_email_user = User.new(@attr.merge(:email => address))
      valid_email_user.should be_valid
    end
  end

	it "devrait rejeter une adresse email invalide" do
    adresses = %w[user@foo foo.bar.org first.last@foo.]
    adresses.each do |address|
      invalid_email_user = User.new(@attr.merge(:email => address))
      invalid_email_user.should_not be_valid
    end
  end

	it "devrait rejeter un email double" do
    # Place un utilisateur avec un email donné dans la BD.
    User.create!(@attr)
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end

	it "devrait rejeter une adresse email invalide jusqu'à la casse" do
    upcased_email = @attr[:email].upcase
    User.create!(@attr.merge(:email => upcased_email))
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end

	#Password-------------------------------------------------------------------------------------
	describe "password validations" do

    it "devrait exiger un mot de passe" do
      User.new(@attr.merge(:password => "", :password_confirmation => "")).
        should_not be_valid
    end

    it "devrait exiger une confirmation du mot de passe qui correspond" do
      User.new(@attr.merge(:password_confirmation => "invalid")).
        should_not be_valid
    end

    it "devrait rejeter les mots de passe (trop) courts" do
      short = "a" * 5
      hash = @attr.merge(:password => short, :password_confirmation => short)
      User.new(hash).should_not be_valid
    end

    it "devrait rejeter les (trop) longs mots de passe" do
      long = "a" * 41
      hash = @attr.merge(:password => long, :password_confirmation => long)
      User.new(hash).should_not be_valid
    end
  end
	#FinPassword-------------------------------------------------------------------------------------
	#Password1-------------------------------------------------------------------------------------
  describe "password encryption" do

	  before(:each) do
	    @user = User.create!(@attr)
	  end

	  it "devrait avoir un attribut  mot de passe crypté" do
	    @user.should respond_to(:encrypted_password)
	  end

		it "devrait définir le mot de passe crypté" do
  	  @user.encrypted_password.should_not be_blank
	  end
		#Password2-------------------------------------------------------------------------------------
		describe "Méthode has_password?" do

	    it "doit retourner true si les mots de passe coïncident" do
	      @user.has_password?(@attr[:password]).should be_true
	    end    

	    it "doit retourner false si les mots de passe divergent" do
	      @user.has_password?("invalide").should be_false
	    end 
			#Password3-------------------------------------------------------------------------------------
			describe "authenticate method" do

			  it "devrait retourner nul en cas d'inéquation entre email/mot de passe" do
			    wrong_password_user = User.authenticate(@attr[:email], "wrongpass")
			    wrong_password_user.should be_nil
			  end

			  it "devrait retourner nil quand un email ne correspond à aucun utilisateur" do
			    nonexistent_user = User.authenticate("bar@foo.com", @attr[:password])
			    nonexistent_user.should be_nil
			  end

			  it "devrait retourner l'utilisateur si email/mot de passe correspondent" do
			    matching_user = User.authenticate(@attr[:email], @attr[:password])
			    matching_user.should == @user
			  end
			end
			#FinPassword3-------------------------------------------------------------------------------------
 		end
		#FinPassword2-------------------------------------------------------------------------------------
  end
	#FinPassword1-------------------------------------------------------------------------------------
	#Debut tests IMC (taille, poidactu, poidideal)==============================================================
	describe "Tests imc" do
		before(:each) do
	    @user = User.create!(@attr)
	  end

		it "devrait donner l'imc correct" do
			goodIMC = @user.poidactu / (@user.taille * @user.taille)
			goodIMC = ((goodIMC*100).round.to_f)/100
			goodIMC.should == @user.imc
		end

		it "devrait contrôler la valeur de l'imc" do
			@user.imc.should < 100
			@user.imc.should > 1
		end
	end
	
	describe "Tests de validité de taille" do
		it "devrait refuser ces tailles (5,-1,a)" do
			grandDadet = User.new(@attr.merge(:taille => 5))
			grandDadet.should_not be_valid
			petitPoucet = User.new(@attr.merge(:taille => -1))
			petitPoucet.should_not be_valid
			benet = User.new(@attr.merge(:taille => "a"))
			benet.should_not be_valid
		end
		it "devrait accepter ces tailles (0.5, 2.72)" do
			grandDadet = User.new(@attr.merge(:taille => 2.72))
			grandDadet.should be_valid
			petitPoucet = User.new(@attr.merge(:taille => 0.5))
			petitPoucet.should be_valid
		end
	end

	describe "Tests de validité de poids" do
		it "devrait refuser ces poids actuels (7000,-1,a)" do
			grandDadet = User.new(@attr.merge(:poidactu => 7000))
			grandDadet.should_not be_valid
			petitPoucet = User.new(@attr.merge(:poidactu => -1))
			petitPoucet.should_not be_valid
			benet = User.new(@attr.merge(:poidactu => "a"))
			benet.should_not be_valid
		end
		it "devrait refuser ces poids idéals (7000,-1,a, un poids supérieur à l'actuel)" do
			grandDadet = User.new(@attr.merge(:poidideal => 7000))
			grandDadet.should_not be_valid
			petitPoucet = User.new(@attr.merge(:poidideal => -1))
			petitPoucet.should_not be_valid
			benet = User.new(@attr.merge(:poidideal => "a"))
			benet.should_not be_valid
			invalidCombi = User.new(@attr.merge(:poidideal => 61, :poidactu => 60))
			invalidCombi.should_not be_valid
		end
		it "devrait accepter ces poids (10, 150)" do
			grandDadet = User.new(@attr.merge(:poidactu => 10, :poidideal => 9))
			grandDadet.should be_valid
			petitPoucet = User.new(@attr.merge(:poidactu => 150, :poidideal => 149))
			petitPoucet.should be_valid
		end
	end
	#Fin test IMC===============================================================================================
end
#Fin User***************************************************************************************************
