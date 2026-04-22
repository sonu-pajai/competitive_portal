class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    current_user.enrollments.expired_but_not_marked.find_each(&:check_expiry!)
    @active_enrollments = current_user.enrollments.active.includes(:course)
    @expired_enrollments = current_user.enrollments.expired.includes(:course)
  end
end
