# == Schema Information
#
# Table name: customers
#
#  id              :bigint           not null, primary key
#  area_code       :string           not null
#  document_number :string
#  email           :string           not null
#  name            :string
#  phone_number    :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class Customer < ApplicationRecord
  paginates_per 25

  has_many :cicles
  has_many :monthly_metrics, class_name: "::CustomerMonthlyMetrics", foreign_key: "customer_id"
  has_many :transactions_monthly_metrics, class_name: "::CustomerTransactionsMonthlyMetrics", foreign_key: "customer_id"

  scope :current_month, -> { where(created_at: current_month_range) }
  scope :by_month,      ->(month) { where(created_at: month_range(month)) }
  scope :by_store,      ->(store_id) { includes(:cicles).joins(:cicles).where(cicles: { store_id: store_id }).distinct }
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
    [ "email", "name", "phone_number" ]
  end

  def current_month_cicles
    current_month_metrics.total_cicles
  end

  def current_month_metrics
    monthly_metrics.last
  end

  def local?(area_code)
    self.area_code == area_code
  end

  def new?(date)
    byebug if self.created_at.month == 2 && self.created_at.year == 2025
    self.created_at.month == date.month && self.created_at.year == date.year
  end

  def month_total_cicles
    current_month_metrics.total_cicles
  end

  private

  class << self
    def current_month_range
      month_range(DateTime.current)
    end

    def month_range(date)
      date.beginning_of_month..date.end_of_month
    end

    def to_csv(store_id)
      customers = by_store(store_id).order(:id)

      CSV.generate do |csv|
        csv << %w[id nome telefone email ciclos data_cadastro ultima_visita]
        customers.each do |c|
          csv << [ c.id, c.name, c.phone_number, c.email, c.cicles.count, first_cicle(c),  last_cicle(c) ]
        end
      end
    end

    def first_cicle(customer)
      customer.cicles.order(:external_id).first.created_at.strftime("%d/%m/%Y")
    end

    def last_cicle(customer)
      customer.cicles.order(:external_id).last.created_at.strftime("%d/%m/%Y")
    end
  end
end
