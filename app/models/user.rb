class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, :trackable

  MAX_DEVICES = 2

  enum :role, { student: 0, admin: 1 }

  has_many :enrollments, dependent: :destroy
  has_many :courses, through: :enrollments
  has_many :video_views, dependent: :destroy
  has_many :device_sessions, dependent: :destroy
  has_many :payments, dependent: :destroy

  validates :name, presence: true

  def enrolled_in?(course)
    enrollment = enrollments.find_by(course: course)
    return false unless enrollment
    enrollment.check_expiry!
  end

  def can_add_device?
    device_sessions.count < MAX_DEVICES
  end

  def admin?
    role == "admin"
  end
end
