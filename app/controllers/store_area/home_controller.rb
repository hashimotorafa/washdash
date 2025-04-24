module StoreArea
  class HomeController < StoreArea::ApplicationController
    def index
      prepare_customers_metrics
      prepare_cycles_metrics
    end

    def monthly
      @month_cycles               = Cycle.by_store(@current_store.id).current_month
      @month_customers            = Customer.includes(:cycles, :monthly_metrics).by_store(@current_store.id).current_month

      @cycles_per_day             = @month_cycles.group_by_day(:created_at).count
      @customers_per_day          = @month_customers.group_by_day(:created_at).count
      @cycles_per_customer        = @month_cycles.joins(:customer).group(:customer_id).count

      @all_customers              = Customer.includes(:cycles, :monthly_metrics).where(id: @month_cycles.pluck(:customer_id).uniq)
    end

    private

    def set_last_update
      @last_update = @current_store.cycles.last.created_at.strftime("%d/%m/%Y - %H:%M:%S")
    end

    def prepare_customers_metrics
      @customers_per_type = customers.group_by_area_code_and_month(@current_store.area_code)
      customer_metrics    = CustomerMonthlyMetrics.includes(customer: :customer_stores).by_store(@current_store.id)

      customer_metrics.each do |metrics|
        month     = metrics.month
        visits    = metrics.visits

        # Define conditions for new/old and local/outside
        if local?(metrics.area_code)
          if new_customer?(month, metrics.customer)
            increment_visit(:local_visits, month, visits)
          else
            increment_visit(:old_local_visits, month, visits)
          end
        else
          if new_customer?(month, metrics.customer)
            increment_visit(:foreign_visits, month, visits)
          else
            increment_visit(:old_foreign_visits, month, visits)
          end
        end
      end
    end

    def local?(area_code)
      area_code == current_store.area_code
    end

    def new_customer?(date, customer)
      customer_store = customer.customer_stores.select { |cs| cs.store_id == current_store.id }.first
      customer_store.first_visit_date.month == date.month && customer_store.first_visit_date.year == date.year
    end

    def time_range
      return [ params[:from_date], params[:until_date] ] if params[:from_date] && params[:until_date]

      [ @current_store.started_at, Date.today ]
    end

    def customers
      @customers ||= Customer.by_store(@current_store.id).by_time_range(*time_range)
    end

    def cycles
      @cycles ||= @current_store.cycles.by_time_range(*time_range)
    end

    def prepare_cycles_metrics
      # Initialize counters for pie charts
      @cycles_count = {
        washer: cycles.where(machine_type: "Lavadora", status: "Efetivado").count,
        dryer: cycles.where(machine_type: "Secadora", status: "Efetivado").count,
        canceled: cycles.where(status: "Estornado").count
      }

      @customers_count = {
        local: customers.where(area_code: @current_store.area_code).count,
        foreign: customers.where.not(area_code: @current_store.area_code).count
      }

      # Initialize data structure for cycles per customer type
      @cycles_per_customer_type = []

      # Get all months for consistent data
      months = months_since_store_opening

      # Add local customer cycles
      local_cycles = cycles.joins(:customer)
                          .where(customers: { area_code: @current_store.area_code })
                          .group_by_month(:created_at)
                          .count

      local_data = {}
      months.each do |month, _|
        local_data[month] = local_cycles[month.to_date.beginning_of_month] || 0
      end
      @cycles_per_customer_type << { type: "local", **local_data }

      # Add foreign customer cycles
      foreign_cycles = cycles.joins(:customer)
                           .where.not(customers: { area_code: @current_store.area_code })
                           .group_by_month(:created_at)
                           .count

      foreign_data = {}
      months.each do |month, _|
        foreign_data[month] = foreign_cycles[month.to_date.beginning_of_month] || 0
      end
      @cycles_per_customer_type << { type: "others", **foreign_data }

      # Calculate average cycles per month
      @avg_cycles_per_month = {}

      # Calculate for washers
      washer_cycles = cycles.where(machine_type: "Lavadora", status: "Efetivado")
                           .group_by_month(:created_at)
                           .count

      months.each do |month, _|
        date = month.to_date.beginning_of_month
        total = washer_cycles[date] || 0
        @avg_cycles_per_month[month] = calculate_avg(date, total)
      end
    end

    def calculate_avg(date, value)
      if current_month(date)
        (value.to_f / Date.today.day).round(1)
      else
        (value.to_f / date.end_of_month.day).round(1)
      end
    end

    def current_month(date)
      Date.today.month == date.month && Date.today.year == date.year
    end

    def months_since_store_opening
      hash = {}
      (@current_store.started_at..Date.today).each do |date|
        hash[date.strftime("%B %Y")] = 0
      end
      hash
    end

    def visits_data
      @visits_data ||= {
        local_visits:       months_since_store_opening,
        foreign_visits:     months_since_store_opening,
        old_local_visits:   months_since_store_opening,
        old_foreign_visits: months_since_store_opening
      }
    end

    def increment_visit(key, month, visits)
      month = month.strftime("%B %Y")
      visits_data[key][month] += visits
    end
  end
end
