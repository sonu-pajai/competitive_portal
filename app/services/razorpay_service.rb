class RazorpayService
  def initialize
    Razorpay.setup(
      Rails.application.credentials.dig(:razorpay, :key_id) || ENV["RAZORPAY_KEY_ID"],
      Rails.application.credentials.dig(:razorpay, :key_secret) || ENV["RAZORPAY_KEY_SECRET"]
    )
  end

  def create_order(amount_in_paise, receipt:, currency: "INR")
    Razorpay::Order.create(
      amount: amount_in_paise,
      currency: currency,
      receipt: receipt
    )
  end

  def verify_payment(razorpay_order_id:, razorpay_payment_id:, razorpay_signature:)
    Razorpay::Utility.verify_payment_signature(
      "razorpay_order_id" => razorpay_order_id,
      "razorpay_payment_id" => razorpay_payment_id,
      "razorpay_signature" => razorpay_signature
    )
    true
  rescue Razorpay::Error
    false
  end
end
