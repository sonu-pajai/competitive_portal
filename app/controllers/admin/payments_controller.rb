class Admin::PaymentsController < Admin::BaseController
  def index
    payments = Payment.includes(:user, enrollment: :course).order(created_at: :desc)
    payments = payments.where(status: params[:status]) if params[:status].present?
    @pagy, @payments = pagy(payments)
  end
end
