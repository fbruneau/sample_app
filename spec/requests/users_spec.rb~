#encoding = UTF-8
require 'spec_helper'

describe "Users" do
  describe "Une inscription" do

    describe "ratée" do

      it "ne devrait pas créer un nouvel utilisateur" do
        lambda do
          visit signup_path
          fill_in "Nom", :with => ""
          fill_in "eMail", :with => ""
          fill_in "Password", :with => ""
          fill_in "Confirmation", :with => ""
          click_button
          response.should render_template('users/new')
          response.should have_selector("div#error_explanation")
        end.should_not change(User, :count)
      end
    end

		describe "réussie" do

      it "devrait créer un nouvel utilisateurr" do
        lambda do
          visit signup_path
          fill_in "Nom", :with => "Example User"
          fill_in "eMail", :with => "user@example.com"
          fill_in "Password", :with => "foobar"
          fill_in "Confirmation", :with => "foobar"
          click_button
          response.should have_selector("div.flash.success",
                                        :content => "Bienvenue")
          response.should render_template('users/show')
        end.should change(User, :count).by(1)
      end
    end
  end

	describe "identification/déconnexion" do

    describe "l'échec" do
      it "ne devrait pas identifier l'utilisateur" do
	user = User.new()
	user.nom = ""
	user.password = ""
	integration_sign_in(user)
        response.should have_selector("div.flash.error", :content => "Combinaison Email/Mot de passe invalide.")
      end
    end

    describe "le succès" do
      it "devrait identifier un utilisateur puis le déconnecter" do
        user = Factory(:user)
        integration_sign_in(user)
        controller.should be_signed_in
        click_link "Déconnexion"
        controller.should_not be_signed_in
      end
    end
  end
end
