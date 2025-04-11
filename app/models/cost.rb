class Cost < ApplicationRecord
  belongs_to :income_statement
  belongs_to :store

  validates :name, :amount, presence: true

  enum :category, {
    maintainance: 1,
    supplies: 2,
    rent: 3,
    marketing: 4,
    operating_costs: 5,
    taxes: 6,
    other: 7
  }

  enum :payment_method, {
    card: 1,
    bank_transfer: 2,
    pix: 3,
    cash: 4,
    banking_billet: 5
  }

  enum :payment_status, {
    pending: 1,
    paid: 2,
    failed: 3
  }
end
