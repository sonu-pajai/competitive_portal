class Admin::UsersController < Admin::BaseController
  def index
    @q = params[:q]
    @filter = params[:filter]
    users = User.student

    users = users.where("name ILIKE ? OR email ILIKE ?", "%#{@q}%", "%#{@q}%") if @q.present?

    case @filter
    when "not_purchased"
      users = users.where.not(id: Enrollment.active.select(:user_id))
    when "purchased"
      users = users.where(id: Enrollment.active.select(:user_id))
    end

    @pagy, @users = pagy(users.order(created_at: :desc))
  end

  def show
    @user = User.find(params[:id])
    @enrollments = @user.enrollments.includes(:course)
    @payments = @user.payments.order(created_at: :desc)
    @device_sessions = @user.device_sessions
  end
end
