class Users::SessionsController < Devise::SessionsController
  after_action :register_device, only: :create

  private

  def register_device
    return unless current_user

    fingerprint = cookies.signed[:device_fingerprint] || SecureRandom.hex(16)
    cookies.signed[:device_fingerprint] = { value: fingerprint, expires: 1.year.from_now, httponly: true }

    manager = DeviceManager.new(current_user)
    manager.register_device!(
      fingerprint: fingerprint,
      device_name: request.user_agent.to_s.truncate(100),
      ip_address: request.remote_ip
    )
  rescue DeviceManager::DeviceLimitExceeded
    sign_out current_user
    redirect_to new_user_session_path, alert: "Device limit reached (max #{User::MAX_DEVICES}). Logout from another device first."
  end
end
