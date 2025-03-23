class Transaction < ApplicationRecord
  belongs_to :customer
  belongs_to :store

  enum :payment_method, {
    card: 1,
    card_reversal: 2,
    pix: 3,
    pix_reversal: 4,
    voucher: 5,
  }

  scope :by_store,      ->(store_id) { where(store_id: store_id) }
  scope :by_month,      ->(month)    { where(created_at: month_range(month)) }
end
