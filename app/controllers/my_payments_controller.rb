class MyPaymentsController < ApplicationController
  before_action :authenticate_user!

  def index
    @pagy, @payments = pagy(current_user.payments.includes(enrollment: :course).order(created_at: :desc))
    @total_spent = current_user.payments.paid.sum(:amount)
  end
end
