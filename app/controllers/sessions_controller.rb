# frozen_string_literal: true

class SessionsController < ActionController::Base
  def googleAuth
    # Get access tokens from the google server
    access_token = request.env['omniauth.auth']
    user = User.from_omniauth(access_token)
    session[:user_id] = user.id
    # Access_token is used to authenticate request made from the rails application to the google server
    redirect_to controller: 'drive', action: 'index'
  end
end
