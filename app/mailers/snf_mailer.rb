class SnfMailer < ActionMailer::Base
  default from: "alert@carzapp.com"

  def alert(user, car)
    @car = car
    @user = user
    mail(to: @user.email, subject: 'New car')
  end
end
