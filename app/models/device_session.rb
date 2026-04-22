class DeviceSession < ApplicationRecord
  belongs_to :user

  validates :device_fingerprint, presence: true
  validates :session_token, presence: true, uniqueness: true

  before_validation :generate_session_token, on: :create

  scope :active, -> { where("last_active_at > ?", 30.days.ago) }

  def touch_activity!
    update!(last_active_at: Time.current)
  end

  private

  def generate_session_token
    self.session_token ||= SecureRandom.hex(32)
  end
end
