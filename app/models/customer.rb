# == Schema Information
#
# Table name: customers
#
#  id              :bigint           not null, primary key
#  name            :string
#  email           :string           not null
#  area_code       :string           not null
#  phone_number    :string           not null
#  is_active       :boolean          default(TRUE)
#  document_number :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class Customer < ApplicationRecord
  paginates_per 25

  has_many :customer_stores, dependent: :destroy
  has_many :stores, through: :customer_stores
  has_many :cycles, dependent: :destroy
  has_many :monthly_metrics, class_name: "::CustomerMonthlyMetrics", foreign_key: "customer_id"
  has_many :transactions
  has_many :transactions_monthly_metrics, class_name: "::CustomerTransactionsMonthlyMetrics", foreign_key: "customer_id"
  has_many :customer_stores
  has_many :stores, through: :customer_stores

  ransacker :first_visit_date do
    Arel.sql("(SELECT cs.first_visit_date FROM customer_stores cs WHERE cs.customer_id = customers.id AND cs.store_id = #{@current_store&.id})")
  end

  ransacker :last_cycle_date do
    Arel.sql("(SELECT MAX(c2.created_at) FROM cycles c2 WHERE c2.customer_id = customers.id)")
  end

  ransacker :cycles_count do
    Arel.sql("(SELECT COUNT(*) FROM cycles c2 WHERE c2.customer_id = customers.id)")
  end

  scope :current_month, -> { where(created_at: current_month_range) }
  scope :by_month,      ->(month) { where(created_at: month_range(month)) }
  scope :by_store,      ->(store_id) { includes(:cycles).joins(:cycles).where(cycles: { store_id: store_id }).distinct }
  scope :by_time_range, ->(from_date, until_date) { where(created_at: from_date..until_date) }
  scope :group_by_area_code_and_month, ->(area_code) do
    select = "TO_CHAR(customers.created_at, 'YYYY/MM') as month_year, CASE WHEN area_code = '#{area_code}' THEN 'local' ELSE 'others' END as type, COUNT(*) as total "

    ActiveRecord::Base.connection.execute(
      "SELECT #{select} FROM customers GROUP BY type, month_year ORDER BY type"
    ).map do |c|
      { type: c["type"], c["month_year"].to_date=>c["total"] }
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[name email phone_number area_code is_active created_at updated_at first_visit_date last_cycle_date cycles_count]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[transactions cycles monthly_metrics]
  end

  def self.ransortable_attributes(auth_object = nil)
    %w[name email phone_number created_at total_amount]
  end

  def current_month_cycles
    current_month_metrics.total_cycles
  end

  def current_month_metrics
    monthly_metrics.last
  end

  def local?(area_code)
    self.area_code == area_code
  end

  def new?(date)
    self.created_at.month == date.month && self.created_at.year == date.year
  end

  def month_total_cycles
    current_month_metrics.total_cycles
  end

  private

  class << self
    def current_month_range
      month_range(DateTime.current)
    end

    def month_range(date)
      date.beginning_of_month..date.end_of_month.end_of_day
    end
  end
end
