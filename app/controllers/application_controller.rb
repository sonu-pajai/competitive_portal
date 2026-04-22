class ApplicationController < ActionController::Base
  include Pagy::Backend
  allow_browser versions: :modern

  before_action :check_device_session, if: :user_signed_in?

  private

  def check_device_session
    fingerprint = cookies.signed[:device_fingerprint]
    return if fingerprint.blank?

    device = current_user.device_sessions.find_by(device_fingerprint: fingerprint)
    if device
      device.touch_activity!
    else
      # Stale cookie — re-register this device instead of logging out
      manager = DeviceManager.new(current_user)
      manager.register_device!(
        fingerprint: fingerprint,
        device_name: request.user_agent.to_s.truncate(100),
        ip_address: request.remote_ip
      )
    end
  rescue DeviceManager::DeviceLimitExceeded
    cookies.delete(:device_fingerprint)
    sign_out current_user
    redirect_to new_user_session_path, alert: "Device limit reached (max #{User::MAX_DEVICES}). Logout from another device first."
  end

  def require_admin!
    redirect_to root_path, alert: "Access denied" unless current_user&.admin?
  end

  def after_sign_in_path_for(resource)
    resource.admin? ? admin_dashboard_path : courses_path
  end
end
