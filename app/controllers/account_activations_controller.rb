class AccountActivationsController < ApplicationController
  include SessionsHelper
  before_action :load_user

  def edit
    if !@user.activated? && @user.authenticated?(:activation, params[:id])
      @user.activate
      log_in @user
      flash[:success] = t ".account_activated"
      redirect_to :root
    else
      flash[:danger] = t ".activated_failed"
      redirect_to :root
  end

  private
  def load_user
    return if @user = User.find_by(email: params[:email])

    flash[:danger] = t ".bad_request"
    redirect_to :root
  end
end
