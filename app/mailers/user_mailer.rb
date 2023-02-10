class UserMailer < ApplicationMailer
  default(
    from: 'Open Piggy Finances <piggy.onrails@gmail.com>',
    reply_to: 'Open Piggy Finances <piggy.onrails@gmail.com>'
  )

  def welcome_email
    attachments.inline["logo.png"] = File.read("#{Rails.root}/app/assets/images/logo_l.png")
    @user = params[:user]
    mail(to: @user.email, subject: 'Welcome to Open Piggy')
  end

  def reset_password
    @user = params[:user]
    mail(to: @user.email, subject: 'Open Piggy - Reset Password')
  end

end