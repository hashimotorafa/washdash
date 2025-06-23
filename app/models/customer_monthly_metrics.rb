# == Schema Information
#
# Table name: customer_monthly_metrics
#
#  customer_id          :bigint
#  area_code            :string
#  store_id             :bigint           primary key
#  month                :datetime
#  visits               :bigint
#  washer_cycles        :bigint
#  dryer_cycles         :bigint
#  canceled_cycles      :bigint
#  total_cycles         :bigint
#  avg_cycles_per_visit :bigint
#  last_visit           :datetime
#  first_visit          :datetime
#  total_spent          :decimal(, )
#  active_days          :bigint
#
class CustomerMonthlyMetrics < ApplicationRecord
  self.primary_key = :store_id

  belongs_to :customer, foreign_key: "customer_id"
  belongs_to :store
  scope :by_store, ->(store_id) { where(store_id: store_id) }
  scope :by_time_range, ->(start_date, end_date) { where(month: start_date..end_date) }

  def self.refresh
    ActiveRecord::Base.connection.execute(
      "REFRESH MATERIALIZED VIEW customer_monthly_metrics;"
    )
  end
end
