class CoursesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]

  def index
    @q = params[:q]
    @category = params[:category]
    courses = Course.published
    courses = courses.where("title ILIKE ?", "%#{@q}%") if @q.present?
    courses = courses.where(exam_category: @category) if @category.present?
    @pagy, @courses = pagy(courses, items: 12)
  end

  def show
    @course = Course.published.find(params[:id])
    @enrolled = user_signed_in? && current_user.enrolled_in?(@course)
  end

  def enroll
    @course = Course.published.find(params[:id])

    if current_user.enrolled_in?(@course)
      redirect_to course_lessons_path(@course), notice: "Already enrolled"
      return
    end

    enrollment = current_user.enrollments.find_or_initialize_by(course: @course)
    enrollment.assign_attributes(status: :pending, amount_paid: @course.price)
    enrollment.save!

    if @course.price.zero?
      enrollment.update!(status: :active, enrolled_at: Time.current, expires_at: @course.duration_days.days.from_now)
      redirect_to course_lessons_path(@course), notice: "Enrolled successfully!"
    else
      service = RazorpayService.new
      order = service.create_order(
        (@course.price * 100).to_i,
        receipt: "enrollment_#{enrollment.id}"
      )

      payment = enrollment.payments.create!(
        user: current_user,
        razorpay_order_id: order.id,
        amount: @course.price,
        status: :pending
      )

      redirect_to new_payment_path(payment_id: payment.id, order_id: order.id)
    end
  rescue Razorpay::BadRequestError => e
    redirect_to @course, alert: "Payment gateway error: #{e.message}"
  end
end
