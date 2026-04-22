class DeviceManager
  def initialize(user)
    @user = user
  end

  def register_device!(fingerprint:, device_name: nil, ip_address: nil)
    existing = @user.device_sessions.find_by(device_fingerprint: fingerprint)
    if existing
      existing.touch_activity!
      return existing
    end

    unless @user.can_add_device?
      raise DeviceLimitExceeded, "Maximum #{User::MAX_DEVICES} devices allowed. Please logout from another device first."
    end

    @user.device_sessions.create!(
      device_fingerprint: fingerprint,
      device_name: device_name,
      ip_address: ip_address,
      last_active_at: Time.current
    )
  end

  def remove_device!(session_id)
    @user.device_sessions.find(session_id).destroy!
  end

  class DeviceLimitExceeded < StandardError; end
end
