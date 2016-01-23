class GeneralMailer < ActionMailer::Base
  default from: "unknown_user@unknown.com"
  
  def contact_us_form(form)
    @name = form[:name]
    @email = form[:email]
    @message = form[:message]
    
    mail(:to=>'admin@example.com',:subject => 'hereYAK Contact Us Form')
  end
end
