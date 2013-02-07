#encoding = UTF-8
class SessionsController < ApplicationController
  def new
		@titre = "Connexion"
  end
	
  def create
		user = User.authenticate(params[:session][:email],
                             params[:session][:password])
    if user.nil?
      flash.now[:error] = "Combinaison Email/Mot de passe invalide."
      @titre = "Connexion"
      render 'new'
    else
			if (params[:session][:remindme] == "1")
     		sign_in user
			else
				sign_in_no_cookie user
			end
			redirect_to user	
    end
  end

  def destroy
    sign_out
    redirect_to root_path
  end
end
