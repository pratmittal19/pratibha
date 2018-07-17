module Spree
	class UserData < ActionMailer::Base

		def send_mail_confirmation(user)
			@user = user
		    mail(:from => 'pratmittal19@gmail.com', :to => "#{user.email}>", :subject => "Registration Confirmation") do |format|
	          format.html { render 'spree/mailers/user_login'}
		end
	end
end
end