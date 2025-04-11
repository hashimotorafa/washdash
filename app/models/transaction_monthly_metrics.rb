
#
class TransactionMonthlyMetrics < ApplicationRecord
  self.primary_key = :store_id

  belongs_to :customer, foreign_key: "customer_id"
  scope :by_store, ->(store_id) { where(store_id: store_id) }
  scope :by_month_and_year, ->(month, year) { where(month: "#{month}/#{year}".to_date) }

  def self.refresh
    ActiveRecord::Base.connection.execute(
      "REFRESH MATERIALIZED VIEW transaction_monthly_metrics;"
    )
  end
end
