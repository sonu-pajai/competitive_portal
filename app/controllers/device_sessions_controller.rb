class DeviceSessionsController < ApplicationController
  before_action :authenticate_user!

  def index
    @device_sessions = current_user.device_sessions.order(last_active_at: :desc)
  end

  def destroy
    session = current_user.device_sessions.find(params[:id])
    session.destroy!
    redirect_to device_sessions_path, notice: "Device removed successfully."
  end
end
