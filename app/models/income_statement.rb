class IncomeStatement < ApplicationRecord
  belongs_to :store
  has_many :transactions, through: :store
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

  def total_before_tax
    transactions_monthly_metrics.sum(:total_before_tax)
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
