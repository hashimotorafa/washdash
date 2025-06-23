# == Schema Information
#
# Table name: income_statements
#
#  id         :bigint           not null, primary key
#  store_id   :bigint           not null
#  year       :integer
#  month      :integer
#  net_profit :decimal(10, 2)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class IncomeStatement < ApplicationRecord
  belongs_to :store
  has_many :transactions, through: :store
  has_many :costs
  validates :year, :month, presence: true

  scope :by_store, ->(store_id) { where(store_id: store_id) }
  scope :by_time_range, ->(start_date, end_date) { where(created_at: start_date..end_date) }
  scope :by_month_year, ->(month, year) { where(month: month, year: year) }
  scope :group_by_month_year, -> { group(:id, :month, :year) }
  scope :order_by_month_year, -> { order(:month, :year) }

  def month_year
    Date.new(year, month, 1).strftime("%m/%Y")
  end

  def transactions_monthly_metrics
    @transactions_monthly_metrics ||= TransactionMonthlyMetrics.by_store(store_id).by_month_and_year(month, year)
  end

  def average_ticket
    transactions_monthly_metrics.sum(:total_spent)/transactions_monthly_metrics.size
  end

  def total_transactions
    transactions_monthly_metrics.sum(:total_transactions)
  end

  def total_before_tax
    transactions_monthly_metrics.sum(:total_spent)
  end

  def total_royalties
    transactions_monthly_metrics.sum(:total_royalties)
  end

  def total_fup
    transactions_monthly_metrics.sum(:total_fup)
  end

  def total_payment_method_tax
    transactions_monthly_metrics.sum(:total_payment_method_tax)
  end

  def total_after_payment_method_tax
    total_before_tax - total_payment_method_tax
  end

  def total_receivable
    transactions_monthly_metrics.sum(:total_receivable)
  end

  def net_income
    total_receivable - total_expenses
  end

  def total_expenses
    costs.sum(:amount)
  end
end
