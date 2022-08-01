class MicropostsController < ApplicationController
  before_action :logged_in_user, only: %i(create destroy)
  before_action :correct_user, only: :destroy

  def create
    @micropost = current_user.microposts.build micropost_params
    if @micropost.save
      flash[:success] = t ".create_success"
      redirect_to root_path
    else
      redirect_to_feed
    end
  end

  def destroy
    if @micropost.destroy
      flash[:success] = t ".delete_success"
    else
      flash[:danger] = t ".delete_fail"
    end
    redirect_to request.referer || root_url
  end

  private
  def redirect_to_feed
    @pagy, @feed_items = pagy current_user.feed,
                              items: Settings.user.per_page
    flash[:danger] = t ".create_failed"
    render "static_pages/home"
  end

  def micropost_params
    params.require(:micropost).permit Micropost::MICROPOST_PARAMS
  end

  def correct_user
    @micropost = current_user.microposts.find_by id: params[:id]
    return if @micropost

    flash[:danger] = t ".invalid"
    redirect_to request.referer || root_url
  end
end
