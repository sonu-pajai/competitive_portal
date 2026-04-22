class Enrollment < ApplicationRecord
  enum :status, { pending: 0, active: 1, expired: 2, cancelled: 3 }

  belongs_to :user
  belongs_to :course
  has_many :payments, dependent: :destroy

  validates :user_id, uniqueness: { scope: :course_id, message: "already enrolled in this course" }

  scope :active, -> { where(status: :active).where("expires_at > ?", Time.current) }
  scope :expired_but_not_marked, -> { where(status: :active).where("expires_at <= ?", Time.current) }

  def valid_enrollment?
    active? && expires_at.present? && expires_at > Time.current
  end

  def expired?
    expires_at.present? && expires_at < Time.current
  end

  # Auto-expire if past expiry date
  def check_expiry!
    if active? && expired?
      update!(status: :expired)
      false
    else
      valid_enrollment?
    end
  end
end
