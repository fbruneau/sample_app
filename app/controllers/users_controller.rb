#encoding = UTF-8
class UsersController < ApplicationController
	before_filter :authenticate, :only => [:edit, :update]
	before_filter :correct_user, :only => [:edit, :update, :destroy]

	def show
    @user = User.find(params[:id])
		@titre = @user.nom
		if( !@user.dob.nil? )
			if(Time.now.month>=@user.dob.month)
				if(Time.now.day>=@user.dob.day)
					@age = Time.now.year - @user.dob.year
				else
					@age = Time.now.year - @user.dob.year
					@age = @age-1 
				end	
			else
				@age = Time.now.year - @user.dob.year
				@age = @age-1 
			end
			if((Time.now.month==@user.dob.month) && (Time.now.day==@user.dob.day))
					@msg = "Bon Anniversaire #{@user.nom}! Né le #{@user.dob.day}/#{@user.dob.month}/#{@user.dob.year}"
			else
				@msg = "Bienvenue sur le profil de  #{@user.nom}!"
			end
		else
			@msg = "Bienvenue sur le profil de  #{@user.nom}!"
		end
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
 
    # Envoi du fichier au client
		@user = User.find(params[:id])
    send_file(@user.cv.path, :type => @user.cv_content_type, :disposition => 'inline')
		#render :file => @user.cv.path, :encoding => "ISO-8859-1" 
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
