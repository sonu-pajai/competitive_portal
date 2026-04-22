class Payment < ApplicationRecord
  enum :status, { pending: 0, paid: 1, failed: 2, refunded: 3 }

  belongs_to :user
  belongs_to :enrollment

  validates :amount, numericality: { greater_than: 0 }
end
