class Post < ApplicationRecord
  IMAGE_TYPES = %w[image/png image/jpeg image/webp image/gif].freeze
  IMAGE_MAX_BYTES = 5.megabytes

  belongs_to :plan
  has_one :creator, through: :plan
  has_one_attached :image

  validates :title, presence: true, length: { maximum: 100 }
  validates :body, presence: true
  validate :acceptable_image

  scope :published, -> { where(published_at: ..Time.current) }
  scope :recent, -> { order(published_at: :desc) }

  def viewable_by?(user)
    return false unless user

    plan.creator_id == user.id || user.subscribed_to?(plan)
  end

  private

  def acceptable_image
    return unless image.attached?

    errors.add(:image, "は PNG / JPEG / WebP / GIF のみです") unless IMAGE_TYPES.include?(image.content_type)
    errors.add(:image, "は 5MB 以下にしてください") if image.byte_size > IMAGE_MAX_BYTES
  end
end
