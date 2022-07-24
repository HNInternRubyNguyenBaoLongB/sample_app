class UsersController < ApplicationController
  before_action :logged_in_user, except: %i(new create)
  before_action :correct_user, only: %i(edit update)
  before_action :load_user, only: %i(show destroy update correct_user)

  def index
    @pagy, @users = pagy User.all, items: Settings.user.per_page
  end

  def new
    @user = User.new
  end

  def show; end

  def edit; end

  def create
    @user = User.new user_params
    if @user.save
      flash[:success] = t "static_pages.home.welcome"
      redirect_to @user
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
      render "edit"
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
    params.require(:user).permit(:name, :email, :password,
                                 :password_confirmation)
  end

  def correct_user
    redirect_to(root_path) unless @user == current_user
  end

  def load_user
    @user = User.find_by id: params[:id]
    return if @user

    flash[:danger] = t ".show.show_user_failed"
    redirect_to root_path
  end
end
