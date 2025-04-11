class IncomeStatement < ApplicationRecord
  belongs_to :store
  has_many :transactions, through: :store
  has_many :transactions_monthly_metrics, through: :store
  has_many :costs
  validates :year, :month, presence: true

  def month_year
    "#{month}/#{year}"
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

  def total_revenue
    transactions_monthly_metrics.sum(:total_receivable)
  end

  def net_income
    total_revenue - total_expenses
  end

  def total_expenses
    costs.sum(:amount)
  end
end
