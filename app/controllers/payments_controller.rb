class PaymentsController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :verify_authenticity_token, only: :webhook

  def new
    @payment = current_user.payments.find(params[:payment_id])
    @razorpay_key = Rails.application.credentials.dig(:razorpay, :key_id) || ENV["RAZORPAY_KEY_ID"]
  end

  def verify
    @payment = current_user.payments.find(params[:id])

    verified = if Rails.env.development? && params[:test_mode].present?
      true
    else
      RazorpayService.new.verify_payment(
        razorpay_order_id: params[:razorpay_order_id],
        razorpay_payment_id: params[:razorpay_payment_id],
        razorpay_signature: params[:razorpay_signature]
      )
    end

    if verified
      @payment.update!(
        status: :paid,
        razorpay_payment_id: params[:razorpay_payment_id],
        razorpay_signature: params[:razorpay_signature]
      )

      enrollment = @payment.enrollment
      enrollment.update!(
        status: :active,
        enrolled_at: Time.current,
        expires_at: enrollment.course.duration_days.days.from_now,
        razorpay_payment_id: params[:razorpay_payment_id],
        razorpay_order_id: params[:razorpay_order_id]
      )

      redirect_to course_lessons_path(enrollment.course), notice: "Payment successful! You are now enrolled."
    else
      @payment.update!(status: :failed)
      redirect_to course_path(@payment.enrollment.course), alert: "Payment verification failed. Please try again."
    end
  end

  def webhook
    payload = JSON.parse(request.body.read)
    event = payload["event"]

    if event == "payment.captured"
      payment_entity = payload.dig("payload", "payment", "entity")
      payment = Payment.find_by(razorpay_order_id: payment_entity["order_id"])
      payment&.update!(status: :paid, razorpay_payment_id: payment_entity["id"]) if payment&.pending?
    end

    head :ok
  end
end
