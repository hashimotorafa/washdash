module StoreArea
  class CustomersController < StoreArea::ApplicationController
    before_action :set_customer, only: [ :show ]
    helper_method :period_text

    ALLOWED_SORT_FIELDS = %w[first_visit_date last_cycle_date cycles_count created_at]

    def index
      @q = current_store.customers.ransack(params[:q])

      start_date       = parse_date(params.dig(:q, :first_visit_date_gteq))
      end_date         = parse_date(params.dig(:q, :first_visit_date_lteq))
      usage_start_date = parse_date(params.dig(:q, :cycles_created_at_gteq))
      usage_end_date   = parse_date(params.dig(:q, :cycles_created_at_lteq))
      min_cycles       = params.dig(:q, :cycles_count_gteq)
      max_cycles       = params.dig(:q, :cycles_count_lteq)

      # Construir a query base usando a view materializada
      base_query = CustomerDailyMetrics
        .for_store(current_store.id)
        .joins(:customer)
        .joins("LEFT JOIN customer_stores cs ON cs.customer_id = customers.id AND cs.store_id = #{current_store.id}")
        .select("customers.*,
                 cs.first_visit_date as first_visit_date,
                 MAX(customer_daily_metrics.date) as last_cycle_date,
                 SUM(customer_daily_metrics.total_cycles) as cycles_count")

      # Aplicar filtros de data
      if start_date.present?
        base_query = base_query.where("cs.first_visit_date >= ?", start_date)
      end

      if end_date.present?
        base_query = base_query.where("cs.first_visit_date <= ?", end_date)
      end

      # Aplicar filtros de uso
      if usage_start_date.present? && usage_end_date.present?
        base_query = base_query.where("customer_daily_metrics.date BETWEEN ? AND ?",
                                    usage_start_date, usage_end_date)
      end

      # Aplicar filtros de número de ciclos
      if min_cycles.present?
        base_query = base_query.having("SUM(customer_daily_metrics.total_cycles) >= ?", min_cycles)
      end

      if max_cycles.present?
        base_query = base_query.having("SUM(customer_daily_metrics.total_cycles) <= ?", max_cycles)
      end

      # Aplicar filtros de busca (nome, email, telefone)
      if params[:q].present?
        search_conditions = []
        search_params = []

        if params.dig(:q, :name_cont).present?
          search_conditions << "customers.name ILIKE ?"
          search_params << "%#{params.dig(:q, :name_cont)}%"
        end

        if params.dig(:q, :email_cont).present?
          search_conditions << "customers.email ILIKE ?"
          search_params << "%#{params.dig(:q, :email_cont)}%"
        end

        if params.dig(:q, :phone_number_cont).present?
          search_conditions << "customers.phone_number ILIKE ?"
          search_params << "%#{params.dig(:q, :phone_number_cont)}%"
        end

        if search_conditions.any?
          base_query = base_query.where(search_conditions.join(" AND "), *search_params)
        end
      end

      # Agrupar por customer e first_visit_date
      base_query = base_query.group("customers.id, customers.name, customers.email, customers.phone_number, cs.first_visit_date")

      # Aplicar ordenação
      sort_param = params.dig(:q, :s)
      if sort_param.present? && ALLOWED_SORT_FIELDS.any? { |field| sort_param.include?(field) }
        # Tratar ordenação especial para campos calculados
        case sort_param
        when /first_visit_date/
          base_query = base_query.order("cs.first_visit_date #{sort_param.include?('desc') ? 'DESC' : 'ASC'}")
        when /last_cycle_date/
          base_query = base_query.order("MAX(customer_daily_metrics.date) #{sort_param.include?('desc') ? 'DESC' : 'ASC'}")
        when /cycles_count/
          base_query = base_query.order("SUM(customer_daily_metrics.total_cycles) #{sort_param.include?('desc') ? 'DESC' : 'ASC'}")
        else
          base_query = base_query.order(sort_param)
        end
      else
        base_query = base_query.order("cs.first_visit_date DESC")
      end

      @customers = base_query.page(params[:page]).per(10)

      # Métricas para gráfico
      setup_metrics_data(base_query)

      respond_to do |format|
        format.html
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("customers_metrics", partial: "store_area/customers/metrics", locals: {
              customers: @customers,
              active_customers: @active_customers,
              inactive_customers: @inactive_customers,
              customers_by_day: @customers_by_day,
              period_text: period_text
            }),
            turbo_stream.update("customers_list", partial: "store_area/customers/list")
          ]
        end
      end
    end

    def show
      @customer = current_store.customers
        .joins("LEFT JOIN customer_daily_metrics ON customer_daily_metrics.customer_id = customers.id")
        .joins("LEFT JOIN customer_stores cs ON cs.customer_id = customers.id AND cs.store_id = #{current_store.id}")
        .select("customers.*,
                 cs.first_visit_date as first_visit_date,
                 MAX(customer_daily_metrics.date) as last_cycle_date,
                 SUM(customer_daily_metrics.total_cycles) as cycles_count")
        .group("customers.id, customers.name, customers.email, customers.phone_number, cs.first_visit_date")
        .find(params[:id])

      render partial: "show", locals: { customer: @customer }
    end

    private

    def set_customer
      @customer = current_store.customers.find(params[:id])
    end

    def parse_date(date_string)
      return nil if date_string.blank?
      Date.parse(date_string) rescue nil
    end

    def period_text
      start_date_param = params.dig(:q, :first_visit_date_gteq)
      end_date_param = params.dig(:q, :first_visit_date_lteq)
      usage_start_param = params.dig(:q, :cycles_created_at_gteq)
      usage_end_param = params.dig(:q, :cycles_created_at_lteq)

      return "Todos os períodos" if [ start_date_param, end_date_param, usage_start_param, usage_end_param ].all?(&:blank?)

      parts = []
      if start_date_param.present? || end_date_param.present?
        parts << "Primeiro ciclo #{start_date_param.present? ? "a partir de #{start_date_param.to_date.strftime('%d/%m/%Y')}" : ""} #{end_date_param.present? ? "até #{end_date_param.to_date.strftime('%d/%m/%Y')}" : ""}"
      end

      if usage_start_param.present? || usage_end_param.present?
        parts << "Utilizaram #{usage_start_param.present? ? "a partir de #{usage_start_param.to_date.strftime('%d/%m/%Y')}" : ""} #{usage_end_param.present? ? "até #{usage_end_param.to_date.strftime('%d/%m/%Y')}" : ""}"
      end

      parts.join(" e ")
    end

    def setup_metrics_data(base_query)
      start_date = parse_date(params.dig(:q, :first_visit_date_gteq))
      end_date = parse_date(params.dig(:q, :first_visit_date_lteq))

      # Determinar o período de agrupamento baseado no intervalo de datas
      period = if start_date && end_date
        days_diff = (end_date - start_date).to_i
        if days_diff <= 30
          :day
        elsif days_diff <= 365
          :month
        else
          :year
        end
      else
        :month # padrão
      end

      # Carregar todos os registros de uma vez
      records = base_query.to_a

      # Filtrar registros com first_visit_date presente
      records_with_date = records.select { |record| record.first_visit_date.present? }

      # Calcular clientes ativos e inativos
      @active_customers = records.count { |record| record.is_active }
      @inactive_customers = records.count { |record| !record.is_active }

      # Agrupar por período e contar usando Ruby puro
      @customers_by_day = records_with_date
        .group_by { |record|
          date = record.first_visit_date.to_date
          case period
          when :day
            date
          when :month
            date.beginning_of_month
          when :year
            date.beginning_of_year
          end
        }
        .transform_values(&:count)
        .sort
        .map { |date, count| [ date, count ] }
    end
  end
end
