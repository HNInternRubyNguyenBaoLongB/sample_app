class Micropost < ApplicationRecord
  MICROPOST_PARAMS = %i(content image).freeze

  belongs_to :user

  has_one_attached :image

  scope :recent_posts, ->{order(created_at: :desc)}
  scope :by_user_ids, ->(user_id){where user_id: user_id}

  validates :user_id, presence: true
  validates :content, presence: true, length:
  {
    maximum: Settings.micropost.content_max_length
  }
  validates :image, content_type:
  {
    in: Settings.micropost.img_type,
    message: I18n.t("models.micropost.valid_img"),
    size:
    {
      less_than: Settings.micropost.img_max_size.megabytes,
      message: I18n.t("models.micropost.less_than")
    }
  }

  def display_image
    image.variant resize_to_limit:
    [
      Settings.micropost.height_limit,
      Settings.micropost.width_limit
    ]
  end
end
