class Admin::DashboardController < Admin::BaseController
  def index
    @total_users = User.student.count
    @total_courses = Course.count
    @total_enrollments = Enrollment.active.count
    @total_revenue = Payment.paid.sum(:amount)
    @not_purchased_count = User.student.where.not(id: Enrollment.active.select(:user_id)).count
    @monthly_revenue = Payment.paid.where("created_at > ?", 30.days.ago).sum(:amount)

    @recent_payments = Payment.paid.includes(:user, enrollment: :course).order(created_at: :desc).limit(10)
    @recent_users = User.student.order(created_at: :desc).limit(10)

    @enrollments_by_day = Enrollment.active.where("enrolled_at > ?", 30.days.ago).group_by_day(:enrolled_at).count
    @revenue_by_day = Payment.paid.where("created_at > ?", 30.days.ago).group_by_day(:created_at).sum(:amount)
    @revenue_by_course = Payment.paid.joins(enrollment: :course).group("courses.title").sum(:amount)
  end
end
