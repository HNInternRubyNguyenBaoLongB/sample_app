class User < ApplicationRecord
  before_save :downcase_email
  attr_accessor :remember_token

  validates :name, presence: true,
  length: {maximum: Settings.user.name.max_length}

  validates :email, presence: true,
  length: {
    minimum: Settings.user.email.min_length,
    maximum: Settings.user.email.max_length
  },
    format: {with: Settings.user.email.regex_format}

  validates :password, presence: true, length:
    {minimum: Settings.user.password.min_length}, if: :password

  has_secure_password

  class << self
    def digest string
      cost = if ActiveModel::SecurePassword.min_cost
               BCrypt::Engine::MIN_COST
             else
               BCrypt::Engine.cost
             end
      BCrypt::Password.create string, cost: cost
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  def remember
    self.remember_token = User.new_token
    update_column :remember_digest, User.digest(remember_token)
  end

  def forget
    update_attribute :remember_digest, nil
  end

  def authenticated? remember_token
    return false unless remember_token

    BCrypt::Password.new(remember_digest).is_password? remember_token
  end

  private
  def downcase_email
    email.downcase!
  end
end
