# == Schema Information
# Schema version: 20240721001550
#
# Table name: cicles
#
#  id             :bigint           not null, primary key
#  description    :string
#  machine_number :string
#  machine_type   :string
#  price          :string
#  status         :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  customer_id    :bigint
#  external_id    :bigint
#  store_id       :bigint
#
# Indexes
#
#  index_cicles_on_customer_id  (customer_id)
#  index_cicles_on_external_id  (external_id) UNIQUE
#  index_cicles_on_store_id     (store_id)
#
class Cicle < ApplicationRecord
  belongs_to :customer
  belongs_to :store

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
          FROM cicles
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
        SELECT CASE WHEN customers.area_code = '#{area_code}' THEN 'local' ELSE 'others' END as type, DATE_TRUNC('month', cicles.created_at) as month_year, COUNT(cicles.id) as total
        FROM "cicles" INNER JOIN "customers" ON "customers"."id" = "cicles"."customer_id"
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
    data = group_by do |cicle|
      cicle.created_at.strftime("%A")
    end.transform_values do |cicles|
      cicles.group_by { |cicle| period_of_day(cicle.created_at) }.transform_values(&:count)
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
