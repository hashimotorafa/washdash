module StoreArea
  class HomeController < StoreArea::ApplicationController
    def index
      # Dados dos últimos 6 meses
      @revenue_data = TransactionMonthlyMetrics
        .by_store(current_store.id)
        .select(
          'DATE_TRUNC(\'month\', month) as month,
           SUM(total_spent) as gross_revenue,
           SUM(total_before_tax) as net_revenue,
           SUM(total_receivable) as receivable'
        )
        .group("DATE_TRUNC('month', month)")
        .order("month DESC")
        .limit(6)

      # Dados de ciclos por tipo de máquina
      @machine_usage_data = CustomerMonthlyMetrics
        .where(store_id: current_store.id)
        .select(
          'SUM(washer_cycles) as washer_cycles,
           SUM(dryer_cycles) as dryer_cycles'
        )
        .group("store_id")
        .first

      # Top 5 clientes
      customer_ids = CustomerMonthlyMetrics
        .select("customer_id")
        .where(store_id: current_store.id)
        .where("DATE_TRUNC('month', month::timestamp) = DATE_TRUNC('month', ?::timestamp)", Date.current)
        .distinct
      @top_customers = Customer.where(id: customer_ids)

      # Dados para o gráfico de barras
      @revenue_chart_data = {
        labels: @revenue_data.map { |d| d.month.strftime("%b/%Y") }.reverse,
        datasets: [
          {
            label: "Receita Bruta",
            data: @revenue_data.map(&:gross_revenue).reverse,
            backgroundColor: "#6366F1",
            borderColor: "#6366F1",
            borderWidth: 1
          },
          {
            label: "Receita Líquida",
            data: @revenue_data.map(&:net_revenue).reverse,
            backgroundColor: "#10B981",
            borderColor: "#10B981",
            borderWidth: 1
          }
        ]
      }

      # Dados para o gráfico de pizza
      @machine_usage_chart_data = {
        labels: [ "Lavadora", "Secadora" ],
        datasets: [ {
          data: [
            @machine_usage_data&.washer_cycles || 0,
            @machine_usage_data&.dryer_cycles || 0
          ],
          backgroundColor: [
            "#6366F1", # Indigo for washer
            "#10B981"  # Emerald for dryer
          ]
        } ]
      }

      # Métricas de performance
      total_cycles = (@machine_usage_data&.washer_cycles || 0) + (@machine_usage_data&.dryer_cycles || 0)
      gross_revenue = @revenue_data.sum(&:gross_revenue)

      @performance_metrics = {
        gross_revenue: gross_revenue,
        net_revenue: @revenue_data.sum(&:net_revenue),
        total_cycles: total_cycles,
        average_ticket: total_cycles.zero? ? 0 : gross_revenue / total_cycles.to_f
      }
    end

    private

    def calculate_growth(values)
      return 0 if values.length < 2
      ((values.first - values.last) / values.last * 100).round(2)
    end
  end
end
