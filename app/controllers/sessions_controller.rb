class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by email: params[:session][:email].downcase
    if user&.authenticate params[:session][:password]
      if user.activated?
        log_in_with_active user
      else
        flash[:danger] = t ".user_in_active"
        redirect_to :root
      end
    else
      flash.now[:danger] = t "invalid_email_password_combination"
      render :new
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_path
  end

  def remember_user user
    params[:session][:remember_me] == "1" ? remember(user) : forget(user)
  end

  private
  def log_in_with_active user
    log_in user
    remember_user user
    redirect_back_or user
  end
end
