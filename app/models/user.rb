class User < ApplicationRecord
  attr_accessor :remember_token
  has_one :desire
  has_one :email
  has_one :birthday
  has_one :body
  has_one :education
  has_one :career
  has_one :address
  has_one :local, foreign_key: :user_id, class_name: Transaction.name
  has_many :conections, foreign_key: :sender_id
  has_many :blogs
  has_many :comments
  has_many :photos
  has_many :blocks
  has_many :reports, foreign_key: :user_id
  has_many :conversations, foreign_key: :sender_id
  has_many :messages
  has_many :conection

  enum genre: {male: 0, female: 1}
  enum status: {
      FA: 0,
      love: 1,
      lovelorn: 2,
      marital: 3,
      divorced: 4,
      separated: 5
    }
  ATTRIBUTES_PARAMS = [:name, :avatar, :nick_name, :genre, :description, :hobby,
   :country, :status, :password, :password_confirmation, :matching,
   email_attributes: Email::ATTRIBUTES_PARAMS, birthday_attributes: Birthday::ATTRIBUTES_PARAMS,
   body_attributes: Body::ATTRIBUTES_PARAMS, career_attributes: Career::ATTRIBUTES_PARAMS,
   desire_attributes: Desire::ATTRIBUTES_PARAMS, education_attributes: Education::ATTRIBUTES_PARAMS].freeze
  mount_base64_uploader :avatar, AvatarUploader
  validates :name, presence: true, length: {maximum: Settings.maximum.length_name}
  has_secure_password
  validates :password, presence: true, length: {minimum: Settings.minimum.length_password}, allow_nil: true
  with_options update_only: true do
    accepts_nested_attributes_for :email
    accepts_nested_attributes_for :birthday
    accepts_nested_attributes_for :body
    accepts_nested_attributes_for :career
    accepts_nested_attributes_for :desire
    accepts_nested_attributes_for :education
  end
  accepts_nested_attributes_for :email, update_only: true
  accepts_nested_attributes_for :birthday, update_only: true
  accepts_nested_attributes_for :body, update_only: true
  accepts_nested_attributes_for :career, update_only: true
  accepts_nested_attributes_for :desire, update_only: true
  accepts_nested_attributes_for :education, update_only: true
  accepts_nested_attributes_for :conection

  def turn_on_matching
    update_columns(matching: true)
  end

  def turn_off_matching
    update_columns(matching: false)
  end

  class << self

    def digest string
      cost =
        if ActiveModel::SecurePassword.min_cost
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
    update_attributes remember_digest: User.digest(remember_token)
  end

  def authenticated? remember_token
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  def forget
    # update_attributes remember_digest: nil
  end
end
