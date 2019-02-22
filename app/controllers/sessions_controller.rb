# frozen_string_literal: true

class SessionsController < ActionController::Base
  def show
    current_user
  end

  def create
    user = User.from_omniauth(request.env['omniauth.auth'])
    session[:user_id] = user.id
    redirect_to controller: 'drive', action: 'index'
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  helper_method :current_user
end
