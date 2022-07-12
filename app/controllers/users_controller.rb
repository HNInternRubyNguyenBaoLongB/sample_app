class UsersController < ApplicationController
  include SessionsHelper
  before_action :logged_in_user, except: %i(new create)
  before_action :load_user, except: %i(index create new)
  before_action :correct_user, only: %i(edit update)

  def index
    @pagy, @users = pagy User.order_by("id", "ASC"),
                         items: Settings.user.per_page
  end

  def new
    @user = User.new
  end

  def show
    @pagy, @microposts = pagy @user.microposts.recent_posts,
                              items: Settings.user.per_page
  end

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

  def following
    @title = t ".title"
    @pagy, @users = pagy @user.following,
                         items: Settings.user.per_page
    render :show_follow
  end

  def followers
    @title = t ".title"
    @pagy, @users = pagy @user.followers,
                         items: Settings.user.per_page
    render :show_follow
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
