class PasswordResetsController < ApplicationController
  before_action :load_user, only: %i(create edit update)
  before_action :valid_user, :check_expiration, only: %i(edit update)

  def new; end

  def create
    @user.create_reset_digest
    @user.send_password_reset_email
    flash[:info] = t ".email_sent"
    redirect_to root_path
  end

  def edit; end

  def update
    if params[:user][:password].empty?
      @user.errors.add :password, "can't be empty"
      render :edit
    elsif @user.update(user_params)
      log_in @user
      flash[:success] = t ".password_reset_success"
      redirect_to @user
    else
      render :edit
    end
  end

  private
  def load_user
    return if @user = User.find_by(email: params.dig(:password_reset, :email)
                      &.downcase || params[:email]&.downcase)

    flash.now[:danger] = t ".email_not_found"
    render :new
  end

  def valid_user
    unless @user.activated? &&
           @user.authenticated?(:reset, params[:id])
      flash[:danger] = t ".bad_request"
      redirect_to root_url
    end
  end

  def check_expiration
    return unless @user.password_reset_expired?

    flash[:danger] = t ".token_time_out"
    redirect_to new_password_reset_url
  end

  def user_params
    params.require(:user).permit :password, :password_confirmation
  end
end
