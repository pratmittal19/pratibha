class Spree::Admin::UserSignupController < Spree::Admin::BaseController
	layout 'spree/layouts/admin'

	def index
	end

	def sign_up
		existing_user = UserLogin.find_by_email(params[:email])
		if !existing_user.blank? && existing_user.email_confirmed
			render :json => {:message => "User already exists"}
		else
			if !existing_user.blank? && (existing_user.email_confirmed == false || existing_user.email_confirmed.nil?)
				UserLogin.find_by_email(params[:email]).delete
			end
			@user = UserLogin.create(:email => params[:email], :password => params[:password])
			@user.set_confirmation_token
      		@user.save(validate: false)
      		render :json => {:message => "Please confirm your email address to continue"}
      		Spree::UserData.send_mail_confirmation(@user).deliver	      	
		end
	end

	def confirm_email		
		@user = UserLogin.find_by_confirm_token(params[:token])
	    if @user
		    @user.validate_email
		    @user.save(validate: true)
		    cookies[:log_in_user]={:value=>"true",:domain=>request.host}
	  		cookies[:email]={:value=>@user.email,:domain=>request.host}
			redirect_to "http://localhost/admin/welcome_page"
	    else
		    flash[:error] = "Sorry. User does not exist"
		    redirect_to root_url
		end
	end

	def welcome_page
		if cookies[:log_in_user] == "true"
			render "welcome_page"
		else
			redirect_to "http://localhost/admin/user_signup"
		end
	end

	def sign_in
		authorized_user = UserLogin.authenticate(params[:email],params[:password])
		if authorized_user
	      flash[:notice] = "Wow Welcome again, you logged in as #{authorized_user.email}"
	      cookies[:log_in_user]={:value=>"true",:domain=>request.host}
	  	  cookies[:email]={:value=>authorized_user.email,:domain=>request.host}
	      render :json => {:success => true}
	    else
	      flash[:notice] = "Invalid Username or Password"
	      flash[:color]= "invalid"
	      render :json => {:success => false}
	    end
	end

	def sign_out
		cookies.delete :email, :domain => request.host
		cookies.delete :log_in_user, :domain => request.host
		redirect_to root_url
	end

end
