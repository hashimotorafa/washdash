# == Schema Information
#
# Table name: costs
#
#  id                  :bigint           not null, primary key
#  name                :string
#  income_statement_id :bigint           not null
#  store_id            :bigint           not null
#  amount              :decimal(10, 2)
#  description         :string
#  category            :integer
#  payment_method      :integer
#  payment_status      :integer
#  payment_date        :date
#  due_date            :date
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
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
