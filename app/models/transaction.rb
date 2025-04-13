# == Schema Information
#
# Table name: transactions
#
#  id                 :bigint           not null, primary key
#  amount             :string
#  payment_method_tax :string
#  sub_acquirer       :string
#  amount_before_tax  :string
#  fup                :string
#  royalties          :string
#  amount_receivable  :string
#  payment_method     :integer
#  transaction_id     :string
#  customer_id        :bigint           not null
#  store_id           :bigint           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
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
