# == Schema Information
#
# Table name: cycles
#
#  id             :bigint           not null, primary key
#  external_id    :bigint
#  status         :string
#  price          :string
#  machine_type   :string
#  machine_number :string
#  description    :string
#  customer_id    :bigint           not null
#  store_id       :bigint           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class Cycle < ApplicationRecord
  belongs_to :customer
  belongs_to :store

  # Ransack configuration
  def self.ransackable_attributes(auth_object = nil)
    [ "created_at", "finished_at", "id", "machine_type", "price", "started_at", "status" ]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "customer" ]
  end

  scope :by_store,      ->(store_id) { where(store_id: store_id) }
  scope :by_month,      ->(month)    { where(created_at: month_range(month)) }
  scope :current_month, -> { where(created_at: current_month_range) }
  scope :today,         -> { where("created_at::date = ?", Date.today) }
  scope :by_time_range, ->(from_date, until_date) { where(created_at: from_date..until_date) }
  scope :by_customers_visits, ->(customer_ids) {
    result = ActiveRecord::Base.connection.execute(
      %Q(
        WITH distinct_visits AS (
          SELECT DISTINCT ON (customer_id, DATE_TRUNC('month', created_at)) customer_id,
          DATE_TRUNC('month', created_at) AS visit_month
          FROM cycles
          WHERE customer_id IN (#{customer_ids.join(', ')})
          ORDER BY customer_id, DATE_TRUNC('month', created_at)
        )
        SELECT visit_month, COUNT(*) AS total_visits
        FROM distinct_visits
        GROUP BY visit_month
        ORDER BY visit_month
      )
    )

    data = {}
    result.each do |row|
      month = row["visit_month"].strftime("%b %Y")
      data[month] = row["total_visits"].to_i
    end
    data
  }
  scope :group_by_area_code_and_month, ->(area_code) {
    ActiveRecord::Base.connection.execute(
      %Q(
        SELECT CASE WHEN customers.area_code = '#{area_code}' THEN 'local' ELSE 'others' END as type, DATE_TRUNC('month', cycles.created_at) as month_year, COUNT(cycles.id) as total
        FROM "cycles" INNER JOIN "customers" ON "customers"."id" = "cycles"."customer_id"
        GROUP BY type, month_year
        ORDER BY type
      )
    ).map do |c|
      { type: c["type"], c["month_year"].to_date=>c["total"] }
    end
  }
  scope :group_by_weekday_and_period, -> {
    week_days    = %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday]
    ordered_days = {}
    data = group_by do |cycle|
      cycle.created_at.strftime("%A")
    end.transform_values do |cycles|
      cycles.group_by { |cycle| period_of_day(cycle.created_at) }.transform_values(&:count)
    end

    week_days.map { |day| ordered_days[day] = data[day] }
    ordered_days
  }


  def canceled?
    status == "Estornado"
  end

  def washer?
    machine_type == "Lavadora"
  end

  def dryer?
    machine_type == "Secadora"
  end

  private

  class << self
    def current_month_range
      month_range(DateTime.current)
    end

    def month_range(date)
      date.beginning_of_month..date.end_of_month
    end

    def period_of_day(datetime)
      hour = datetime.hour
      case hour
      when 6...12 then :morning
      when 12...18 then :afternoon
      else :evening
      end
    end
  end
end
