# == Schema Information
#
# Table name: customer_monthly_metrics
#
#  active_days          :bigint
#  area_code            :string
#  avg_cicles_per_visit :bigint
#  canceled_cicles      :bigint
#  dryer_cicles         :bigint
#  first_visit          :datetime
#  last_visit           :datetime
#  month                :datetime
#  total_cicles         :bigint
#  total_spent          :decimal(, )
#  visits               :bigint
#  washer_cicles        :bigint
#  customer_id          :bigint
#  store_id             :bigint           primary key
#
# Indexes
#
#  index_customer_monthly_metrics_on_customer_id  (customer_id)
#  index_customer_monthly_metrics_on_store_id     (store_id)
#
class CustomerMonthlyMetrics < ApplicationRecord
  self.primary_key = :store_id

  belongs_to :customer, foreign_key: "customer_id"
  scope :by_store, ->(store_id) { where(store_id: store_id) }


  def self.refresh
    ActiveRecord::Base.connection.execute(
      "REFRESH MATERIALIZED VIEW customer_monthly_metrics;"
    )
  end
end
