#encoding = UTF-8

require 'spec_helper'

#Debut UsersController###################################################################################
describe UsersController do
	render_views

#Debut GET 'new'========================================================================================
  describe "GET 'new'" do
		  it "should be successful" do
		    get 'new'
		    response.should be_success
		  end

		it "should have a title" do
		    get 'new'
		    response.should have_selector("title", :content => "Inscription")
		  end
		it "devrait avoir un champ nom" do
		    get :new
		    response.should have_selector("input[name='user[nom]'][type='text']")
		  end

		  it "devrait avoir un champ email" do
				get :new
		    response.should have_selector("input[name='user[email]'][type='text']")
		  end


		  it "devrait avoir un champ mot de passe" do
				get :new
		    response.should have_selector("input[name='user[password]'][type='password']")
		  end


		  it "devrait avoir un champ confirmation du mot de passe" do
				get :new
		    response.should have_selector("input[name='user[password_confirmation]'][type='password']")
		  end
  end
#Fin GET 'new'========================================================================================
#Debut GET 'show'========================================================================================
	describe "GET 'show'" do

    before(:each) do
      @user = Factory(:user)
    end

    it "devrait réussir" do
      get :show, :id => @user
      response.should be_success
    end

    it "devrait trouver le bon utilisateur" do
      get :show, :id => @user
      assigns(:user).should == @user
    end

    it "devrait avoir le bon titre" do
      get :show, :id => @user
      response.should have_selector("title", :content => @user.nom)
    end

    it "devrait inclure le nom de l'utilisateur" do
      get :show, :id => @user
      response.should have_selector("h1", :content => @user.nom)
    end

    it "devrait avoir une image de profil" do
      get :show, :id => @user
      response.should have_selector("h1>img", :class => "gravatar")
    end
  end
#Fin GET 'show'========================================================================================
#Debut POST 'create'========================================================================================
	describe "POST 'create'" do
		#Debut tests d'échecs----------------------------------------------------------------------------
    describe "échec" do

      before(:each) do
        @attr = { :nom => "", :email => "", :password => "",
                  :password_confirmation => ""  }
      end

      it "ne devrait pas créer d'utilisateur" do
        lambda do
          post :create, :user => @attr
        end.should_not change(User, :count)
      end

      it "devrait avoir le bon titre" do
        post :create, :user => @attr
        response.should have_selector("title", :content => "Inscription")
      end

      it "devrait rendre la page 'new'" do
        post :create, :user => @attr
        response.should render_template('new')
      end
    end
		#fin tests d'échecs----------------------------------------------------------------------------
		#Debut tests de succès----------------------------------------------------------------------------
		describe "succès" do

		    before(:each) do
		      @attr = { :nom => "New User", :email => "user@example.com",
		                :password => "foobar", :password_confirmation => "foobar", :dob => DateTime.now, :poidactu => "60",:poidideal => "59",:taille => "1.7" }
		    end

		    it "devrait créer un utilisateur" do
		      lambda do
		        post :create, :user => @attr
		      end.should change(User, :count).by(1)
		    end

				it "devrait identifier l'utilisateur" do
		      post :create, :user => @attr
		      controller.should be_signed_in
		    end

		    it "devrait rediriger vers la page d'affichage de l'utilisateur" do
		      post :create, :user => @attr
		      response.should redirect_to(user_path(assigns(:user)))
		    end    

				it "devrait avoir un message de bienvenue" do
		      post :create, :user => @attr
		      flash[:success].should =~ /Bienvenue dans l'Application Exemple/i
		    end
		 end
		#fin tests de succès----------------------------------------------------------------------------
  end
#Fin POST 'create'========================================================================================
#Début GET 'edit'========================================================================================
	describe "GET 'edit'" do

    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)
    end

    it "devrait réussir" do
      get :edit, :id => @user
      response.should be_success
    end

    it "devrait avoir le bon titre" do
      get :edit, :id => @user
      response.should have_selector("title", :content => "Édition profil")
    end

    it "devrait avoir un lien pour changer l'image Gravatar" do
      get :edit, :id => @user
      gravatar_url = "http://gravatar.com/emails"
      response.should have_selector("a", :href => gravatar_url,
                                         :content => "changer")
    end
  end
#Fin GET 'edit'========================================================================================
#Début PUT 'update'========================================================================================
	describe "PUT 'update'" do

    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)
    end
		#Debut tests echec -----------------------------------------------------------------------------------------
    describe "Échec" do

      before(:each) do
        @attr = { :email => "", :nom => "", :password => "",
                  :password_confirmation => "" }
      end

      it "devrait retourner la page d'édition" do
        put :update, :id => @user, :user => @attr
        response.should render_template('edit')
      end

      it "devrait avoir le bon titre" do
        put :update, :id => @user, :user => @attr
        response.should have_selector("title", :content => "Édition profil")
      end
    end
		#Fin tests echec ------------------------------------------------------------------------------------
		#Debut tests succès -----------------------------------------------------------------------------------------
    describe "succès" do

      before(:each) do
        @attr = { :nom => "New Name", :email => "user@example.org",
                  :password => "barbaz", :password_confirmation => "barbaz" }
      end

      it "devrait modifier les caractéristiques de l'utilisateur" do
        put :update, :id => @user, :user => @attr
        @user.reload
        @user.nom.should  == @attr[:nom]
        @user.email.should == @attr[:email]
      end

      it "devrait rediriger vers la page d'affichage de l'utilisateur" do
        put :update, :id => @user, :user => @attr
        response.should redirect_to(user_path(@user))
      end

      it "devrait afficher un message flash" do
        put :update, :id => @user, :user => @attr
        flash[:success].should =~ /actualisé/
      end
    end
		#Fin tests succès ----------------------------------------------------------------------------------------
  end
#Fin PUT 'update'========================================================================================
#Debut test authentification =========================================================================================
	describe "authentification des pages edit/update" do

    before(:each) do
      @user = Factory(:user)
    end
		#---------------------------------------------------------------------------------------------------------------
    describe "pour un utilisateur non identifié" do

      it "devrait refuser l'acccès à l'action 'edit'" do
        get :edit, :id => @user
        response.should redirect_to(signin_path)
      end

      it "devrait refuser l'accès à l'action 'update'" do
        put :update, :id => @user, :user => {}
        response.should redirect_to(signin_path)
      end
    end
		#---------------------------------------------------------------------------------------------------------------
		describe "pour un utilisateur identifié" do

      before(:each) do
        wrong_user = Factory(:user, :email => "user@example.net")
        test_sign_in(wrong_user)
      end

      it "devrait correspondre à l'utilisateur à éditer" do
        get :edit, :id => @user
        response.should redirect_to(root_path)
      end

      it "devrait correspondre à l'utilisateur à actualiser" do
        put :update, :id => @user, :user => {}
        response.should redirect_to(root_path)
      end
    end
		#---------------------------------------------------------------------------------------------------------------
  end
#Fin test authentification =========================================================================================
end
#Fin UsersController###################################################################################
