#encoding = UTF-8
class UsersController < ApplicationController
	before_filter :authenticate, :only => [:edit, :update]
	before_filter :correct_user, :only => [:edit, :update, :destroy]

	def show
    @user = User.find(params[:id])
		@titre = @user.nom
  end  

	def new
		@user = User.new
		@titre = "Inscription"
  end

	def create
		if(params[:user][:cv].nil?)
			@user = User.new(params[:user].merge(:cv => nil))
		else
			@user = User.new(params[:user])
		end
	  @user = User.new(params[:user].merge(:cv => @file))
	  if @user.save
			sign_in @user
	    flash[:success] = "Bienvenue dans l'Application Exemple!"
	    redirect_to @user
	  else
	    	@titre = "Inscription"
				@user.password =""
				@user.password_confirmation =""
	    	render 'new'
	  end
  end

	def edit
    @user = User.find(params[:id])
    @titre = "Édition profil"
  end

	def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:success] = "Profil actualisé."
      redirect_to @user
    else
      @titre = "Édition profil"
      render 'edit'
    end
  end

	def index
		@titre = "Tous les utilisateurs"
    @users = User.all
	end

	def destroy
    User.find(params[:id]).destroy
    flash[:success] = "Utilisateur supprimé."
    redirect_to root_path
  end

	def downloadCV
    # Récup le chemin du fichier à partir de l'id
 
    # Recherche du type mime à envoyer au client.
 
    # Envoi du fichier au client
		@user = User.find(params[:id])
    send_file(@user.cv.path, :type => @user.cv_content_type)
  end

	def deleteCVID
    @user = User.find(params[:id])

		redirect_to edit_user_path(@user)
  end

	private
		def authenticate
      deny_access unless signed_in?
    end
		
		def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user)
    end
end
