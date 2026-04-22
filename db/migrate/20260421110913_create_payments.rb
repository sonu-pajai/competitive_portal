class CreatePayments < ActiveRecord::Migration[8.0]
  def change
    create_table :payments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :enrollment, null: false, foreign_key: true
      t.string :razorpay_order_id
      t.string :razorpay_payment_id
      t.string :razorpay_signature
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :currency, default: "INR"
      t.integer :status, default: 0, null: false

      t.timestamps
    end

    add_index :payments, :razorpay_order_id, unique: true
    add_index :payments, :razorpay_payment_id, unique: true
  end
end
