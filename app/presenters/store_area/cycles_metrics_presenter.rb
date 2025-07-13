module StoreArea
  class CyclesMetricsPresenter < BasePresenter
    def initialize(store:, accounting_period:)
      @store = store
      @cycles = @store.cycles
      @accounting_period = accounting_period
    end

    def wash_cycles
      current_month_cycles.by_machine_type("washer").count
    end

    def dry_cycles
      current_month_cycles.by_machine_type("dryer").count
    end

    def cancelled_cycles
      current_month_cycles.where(status: "Estornado").count
    end

    def previous_wash_cycles
      previous_month_cycles.by_machine_type("washer").count
    end

    def previous_dry_cycles
      previous_month_cycles.by_machine_type("dryer").count
    end

    def previous_cancelled_cycles
      previous_month_cycles.where(status: "Estornado").count
    end

    def wash_cycles_percentage
      calculate_percentage(wash_cycles, previous_wash_cycles)
    end

    def dry_cycles_percentage
      calculate_percentage(dry_cycles, previous_dry_cycles)
    end

    def average_cycles
      if current_month?(@accounting_period)
        current_month_cycles.count / Date.today.day
      else
        current_month_cycles.count / @accounting_period.end_of_month.day
      end
    end

    def previous_average_cycles
      previous_month_cycles.count / previous_accounting_period.end_of_month.day
    end

    def average_cycles_percentage
      calculate_percentage(average_cycles, previous_average_cycles)
    end

    def cancelled_cycles_percentage
      calculate_percentage(cancelled_cycles, previous_cancelled_cycles)
    end

    def cycles_charts
      @cycles_charts ||= {
        average_cycles: average_cycles_per_day,
        cycles_per_weekday_and_period: cycles_per_weekday_and_period,
        cancelled_cycles: cancelled_cycles_per_month,
      }
    end

    private

    def current_month_cycles
      @current_month_cycles ||= @cycles.by_time_range(*time_range)
    end

    def previous_month_cycles
      @previous_month_cycles ||= @cycles.by_time_range(previous_accounting_period.beginning_of_month, previous_accounting_period.end_of_month.end_of_day)
    end

    def cancelled_cycles_per_month
      @cancelled_cycles_per_month ||= begin
        cancelled_cycles = twelve_months
        @cycles.by_time_range(*twelve_months_time_range).where(status: "Estornado").group_by_month(:created_at).count.each do |month, cycles|
          cancelled_cycles[month.strftime("%m/%Y")] = cycles
        end
        cancelled_cycles
      end
    end

    def average_cycles_per_day
      @average_cycles_per_day ||= begin
        average_cycles = twelve_months
        @cycles.by_time_range(*twelve_months_time_range).group_by_month(:created_at).count.each do |month, cycles|
          average_cycles[month.strftime("%m/%Y")] = calculate_avg(month, cycles)
        end
        average_cycles
      end
    end

    def calculate_avg(date, value)
      if current_month?(date)
        (value.to_f / Date.today.day).round(1)
      else
        (value.to_f / date.end_of_month.day).round(1)
      end
    end

    def cycles_per_weekday_and_period
      @cycles_per_weekday_and_period ||= begin
        [
          {
            name: "Noite",
            data: @store.cycles.group_by_weekday_and_period.transform_values { |periods| periods.present? ? periods[:evening] : 0 },
            color: "#1f507a"
          },
          {
            name: "Tarde",
            data: @store.cycles.group_by_weekday_and_period.transform_values { |periods| periods.present? ? periods[:afternoon] : 0 },
            color: "#F7B632"
          },
          {
            name: "Manhã",
            data: @store.cycles.group_by_weekday_and_period.transform_values { |periods| periods.present? ? periods[:morning] : 0 },
            color: "#3692e2"
          }
        ]
      end
    end
  end
end
