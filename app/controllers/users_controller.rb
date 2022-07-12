class UsersController < ApplicationController
  before_action :logged_in_user, except: %i(new create)
  before_action :load_user, only: %i(show destroy update)
  before_action :correct_user, only: %i(show edit update)

  def index
    @pagy, @users = pagy User.order_by("id", "ASC"), items: Settings.user.per_page
  end

  def new
    @user = User.new
  end

  def show; end

  def edit; end

  def create
    @user = User.new user_params
    if @user.save
      @user.send_mail_activate
      flash[:info] = t ".user.check_mail"
      redirect_to login_path
    else
      flash.now[:danger] = t ".alert_not_save"
      render :new
    end
  end

  def update
    if @user.update(user_params)
      flash[:success] = t ".update_success"
      redirect_to @user
    else
      render :edit
      flash[:danger] = t ".update_fail"
    end
  end

  def destroy
    if @user.destroy
      flash[:success] = t ".user.delete_success"
    else
      flash[:danger] = t ".user.delete_fail"
    end
    redirect_to users_path
  end

  private

  def user_params
    params.require(:user).permit(User::UPDATABLE_ATTRS)
  end

  def correct_user
    return if current_user? @user

    flash[:danger] = t ".correct_user.alert_correct_user"
    redirect_to root_url
  end

  def load_user
    @user = User.find_by id: params[:id]
    return if @user

    flash[:danger] = t ".show.show_user_failed"
    redirect_to root_path
  end
end
