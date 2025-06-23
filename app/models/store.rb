# == Schema Information
#
# Table name: stores
#
#  id          :bigint           not null, primary key
#  name        :string
#  area_code   :string
#  external_id :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  company_id  :bigint
#  started_at  :date
#
class Store < ApplicationRecord
  # Associations
  belongs_to :company

  has_many :transactions
  has_many :cycles
  has_many :customer_stores
  has_many :customers, through: :customer_stores
  has_many :customer_monthly_metrics, class_name: 'CustomerMonthlyMetrics'
  has_many :income_statements
  has_many :costs
  # Validations
  validates :name, presence: true
  validates :area_code, presence: true
  validates :external_id, presence: true, uniqueness: { scope: :company_id }
  validates :started_at, presence: true

  # Scopes
  scope :ordered, -> { order(created_at: :desc) }

  def income_statement
    transactions_monthly_metrics.sum(:total_receivable) - costs.sum(:amount)
  end

  def transactions_monthly_metrics
    @transactions_monthly_metrics ||= TransactionMonthlyMetrics.by_store(id)
  end
end
