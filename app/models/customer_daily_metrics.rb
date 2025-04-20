# == Schema Information
#
# Table name: customer_daily_metrics
#
#  store_id      :bigint           primary key
#  customer_id   :bigint           primary key
#  date          :date             primary key
#  total_cycles  :integer
#  dryer_cycles  :integer
#  washer_cycles :integer
#
class CustomerDailyMetrics < ApplicationRecord
  self.primary_key = [ :store_id, :customer_id, :date ]

  belongs_to :store
  belongs_to :customer

  def self.refresh
    connection.execute("REFRESH MATERIALIZED VIEW customer_daily_metrics;")
  end

  def self.for_store(store_id)
    where(store_id: store_id)
  end

  def self.for_customer(customer_id)
    where(customer_id: customer_id)
  end

  def self.between_dates(start_date, end_date)
    where(date: start_date..end_date)
  end

  def self.aggregate_by_date(store_id, start_date = nil, end_date = nil)
    query = for_store(store_id)
    query = query.between_dates(start_date, end_date) if start_date && end_date

    query.group(:date)
         .select(
           :date,
           "SUM(total_cycles) as total_cycles",
           "SUM(dryer_cycles) as dryer_cycles",
           "SUM(washer_cycles) as washer_cycles"
         )
         .order(:date)
  end
end
