module StoreArea
  class FinancialMetricsPresenter < BasePresenter
    attr_reader :chart

    def initialize(store:, accounting_period:, month_cycles:, month_customers:)
      @store = store
      @accounting_period = accounting_period
      @month_cycles = month_cycles
      @month_customers = month_customers
      @chart = initialize_chart
      prepare_chart
    end

    def revenue
      income_statement&.total_receivable&.round(2) || 0
    end

    def revenue_percentage
      return 0 if previous_income_statement&.total_receivable.nil?
      calculate_percentage(revenue, previous_income_statement&.total_receivable&.round(2) || 0)
    end

    def costs
      income_statement&.total_expenses&.round(2) || 0
    end

    def costs_percentage
      return 0 if previous_income_statement&.total_expenses.nil?
      calculate_percentage(costs, previous_income_statement&.total_expenses&.round(2) || 0)
    end

    def profit
      income_statement&.net_income&.round(2) || 0
    end

    def profit_percentage
      return 0 if previous_income_statement&.net_income.nil?
      calculate_percentage(profit, previous_income_statement&.net_income&.round(2) || 0)
    end

    def average_ticket
      return 0 if income_statement&.total_receivable.nil?
      (income_statement&.total_receivable.to_f / @month_customers.count).round(2) || 0
    end

    def average_ticket_percentage
      return 0 if previous_income_statement&.total_receivable.nil?
      calculate_percentage(average_ticket, previous_income_statement&.total_receivable.to_f / @month_customers.count&.round(2) || 0)
    end

    def average_cost
      return 0 if income_statement&.costs.nil?
      (income_statement&.costs&.sum(:amount)&.to_f / @month_cycles.count|| 0).round(2)
    end

    def average_cost_percentage
      return 0 if previous_income_statement&.costs.nil?
      calculate_percentage(average_cost, previous_income_statement&.costs&.sum(:amount)&.to_f / @month_cycles.count&.round(2) || 0)
    end

    def prepare_chart
      chart_income_statements.each do |income_statement|
        @chart[:revenue][income_statement.month_year] = income_statement.total_receivable
        @chart[:costs][income_statement.month_year] = income_statement.total_expenses
        @chart[:profit][income_statement.month_year] = income_statement.net_income
      end
    end

    private

    def initialize_chart
      @chart = {
        revenue: twelve_months,
        costs: twelve_months,
        profit: twelve_months
      }
    end

    def income_statement
      @income_statement ||= IncomeStatement
        .includes(:costs, :transactions)
        .by_store(@store.id)
        .find_by(month: @accounting_period.month, year: @accounting_period.year)
    end

    def previous_income_statement
      @previous_income_statement ||= IncomeStatement
        .includes(:costs, :transactions)
        .by_store(@store.id)
        .find_by(month: previous_accounting_period.month, year: previous_accounting_period.year)
    end

    def chart_income_statements
      @chart_income_statements ||= IncomeStatement
        .includes(:costs)
        .by_store(@store.id)
        .by_time_range(*twelve_months_time_range)
        .group_by_month_year
        .order_by_month_year
    end
  end
end
