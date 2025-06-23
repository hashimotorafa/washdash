module StoreArea
  class CustomerMetricsPresenter < BasePresenter
    def initialize(store:, accounting_period:)
      @store = store
      @accounting_period = accounting_period
      @visits_data = initialize_visits_data
      @customer_data = initialize_customer_data
      prepare_visits_data
    end

    def total_customers
      @customer_data[:local_customers][@accounting_period.strftime("%m/%Y")] +
      @customer_data[:foreign_customers][@accounting_period.strftime("%m/%Y")] +
      @customer_data[:old_local_customers][@accounting_period.strftime("%m/%Y")] +
      @customer_data[:old_foreign_customers][@accounting_period.strftime("%m/%Y")]
    end

    def previous_total_customers
      @customer_data[:local_customers][previous_accounting_period.strftime("%m/%Y")] +
      @customer_data[:foreign_customers][previous_accounting_period.strftime("%m/%Y")] +
      @customer_data[:old_local_customers][previous_accounting_period.strftime("%m/%Y")] +
      @customer_data[:old_foreign_customers][previous_accounting_period.strftime("%m/%Y")]
    end

    def new_customers_total
      @customer_data[:local_customers][@accounting_period.strftime("%m/%Y")] + @customer_data[:foreign_customers][@accounting_period.strftime("%m/%Y")]
    end

    def new_local_customers
      @customer_data[:local_customers][@accounting_period.strftime("%m/%Y")]
    end

    def new_foreign_customers
      @customer_data[:foreign_customers][@accounting_period.strftime("%m/%Y")]
    end

    def new_customers_percentage
      calculate_percentage(new_customers_total, old_customers_total)
    end

    def old_customers_total
      @customer_data[:old_local_customers][@accounting_period.strftime("%m/%Y")] + @customer_data[:old_foreign_customers][@accounting_period.strftime("%m/%Y")]
    end

    def old_local_customers
      @customer_data[:old_local_customers][@accounting_period.strftime("%m/%Y")]
    end

    def old_foreign_customers
      @customer_data[:old_foreign_customers][@accounting_period.strftime("%m/%Y")]
    end

    def lost_local_customers
      @customer_data[:local_customers][@accounting_period.strftime("%m/%Y")] - @customer_data[:old_local_customers][previous_accounting_period.strftime("%m/%Y")]
    end

    def lost_foreign_customers
      @customer_data[:foreign_customers][@accounting_period.strftime("%m/%Y")] - @customer_data[:old_foreign_customers][@accounting_period.strftime("%m/%Y")]
    end

    def lost_customers_total
      (total_customers - previous_total_customers)*-1
    end

    def lost_customers_percentage
      calculate_percentage(total_customers, previous_total_customers)*-1
    end

    def old_customers_percentage
      calculate_percentage(old_customers_total, previous_total_customers)
    end

    def column_chart_data
      [
        {
          name: "Clientes Locais Novos",
          data: @customer_data[:local_customers].transform_values { |v| v || 0 },
          color: "#43BCCD"
        },
        {
          name: "Clientes Externos Novos",
          data: @customer_data[:foreign_customers].transform_values { |v| v || 0 },
          color: "#F86624"
        },
        {
          name: "Clientes Locais Recorrentes",
          data: @customer_data[:old_local_customers].transform_values { |v| v || 0 },
          color: "#3692e2"
        },
        {
          name: "Clientes Externos Recorrentes",
          data: @customer_data[:old_foreign_customers].transform_values { |v| v || 0 },
          color: "#F7B632"
        }
      ]
    end
    private

    def customers
      @customers ||= Customer.by_store(@store.id).by_time_range(*time_range)
    end

    def new_customer?(date, customer)
      customer_store = customer.customer_stores.select { |cs| cs.store_id == @store.id }.first
      customer_store.first_visit_date.month == date.month && customer_store.first_visit_date.year == date.year
    end

    def local?(area_code)
      area_code == @store.area_code
    end

    def increment_visit(key, month, visits)
      month = month.strftime("%m/%Y")
      @visits_data[key][month] += visits
    end

    def initialize_visits_data
      @visits_data ||= {
        local_visits:       twelve_months,
        foreign_visits:     twelve_months,
        old_local_visits:   twelve_months,
        old_foreign_visits: twelve_months
      }
    end

    def initialize_customer_data
      @customer_data ||= {
        local_customers:       twelve_months,
        foreign_customers:     twelve_months,
        old_local_customers:   twelve_months,
        old_foreign_customers: twelve_months
      }
    end

    def update_customer_data(key, month)
      month = month.strftime("%m/%Y")
      @customer_data[key][month] += 1
    rescue
      byebug
    end

    def prepare_visits_data
      customer_metrics.each do |metrics|
        month  = metrics.month
        byebug if month == '08/2024'
        visits = metrics.visits

        # Define conditions for new/old and local/outside
        if local?(metrics.area_code)
          if new_customer?(month, metrics.customer)
            update_customer_data(:local_customers, month)
          else
            update_customer_data(:old_local_customers, month)
          end
        else
          if new_customer?(month, metrics.customer)
            update_customer_data(:foreign_customers, month)
          else
            update_customer_data(:old_foreign_customers, month)
          end
        end
      end
    end

    def customer_metrics
      @customer_metrics ||= CustomerMonthlyMetrics.includes(customer: :customer_stores).by_time_range(*twelve_months_time_range).by_store(@store.id)
    end
  end
end
