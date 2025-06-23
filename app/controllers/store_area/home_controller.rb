module StoreArea
  class HomeController < StoreArea::ApplicationController
    before_action :accounting_period
    def index
      @revenue_goal = nil

      @financial_metrics = StoreArea::FinancialMetricsPresenter.new(
        store: @current_store,
        accounting_period: accounting_period,
        month_cycles: @current_store.cycles.by_time_range(*time_range),
        month_customers: CustomerMonthlyMetrics.by_store(@current_store.id).by_time_range(*time_range)
      )

      @customers_metrics = StoreArea::CustomerMetricsPresenter.new(
        store: @current_store,
        accounting_period: accounting_period,
      )

      @cycles_metrics = StoreArea::CyclesMetricsPresenter.new(
        store: @current_store,
        accounting_period: accounting_period,
      )
    end

    private
    def accounting_period
      @accounting_period ||= params[:month] ? params[:month].gsub("-", "/").to_date : Date.today
    end

    def time_range
      [ @accounting_period.beginning_of_month, @accounting_period.end_of_month.end_of_day ]
    end
  end
end
