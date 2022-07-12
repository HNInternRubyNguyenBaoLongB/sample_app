module UserHelper
  def gravatar_for user, _options = {size: Settings.user.gravatar.size}
    gravatar_id = Digest::MD5.hexdigest(user.email.downcase)
    size = options[:size]
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    image_tag(gravatar_url, alt: user.name, class: "gravatar")
  end

  def show_delete? user
    current_user.admin? && !current_user?(user)
  end
end
