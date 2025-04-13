# == Schema Information
#
# Table name: transaction_monthly_metrics
#
#  customer_id              :bigint
#  area_code                :string
#  store_id                 :bigint           primary key
#  month                    :datetime
#  card                     :bigint
#  card_reversal            :bigint
#  pix                      :bigint
#  pix_reversal             :bigint
#  voucher                  :bigint
#  total_transactions       :bigint
#  total_spent              :decimal(, )
#  total_receivable         :decimal(, )
#  total_before_tax         :decimal(, )
#  total_royalties          :decimal(, )
#  total_fup                :decimal(, )
#  total_payment_method_tax :decimal(, )
#
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
