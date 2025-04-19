module StoreArea
  class CustomersController < StoreArea::ApplicationController
    before_action :set_customer, only: [ :show ]
    helper_method :period_text

    ALLOWED_SORT_FIELDS = %w[first_cycle_date last_cycle_date cycles_count created_at]

    def index
      @q = current_store.customers.ransack(params[:q])

      start_date       = parse_date(params.dig(:q, :first_cycle_date_gteq))
      end_date         = parse_date(params.dig(:q, :first_cycle_date_lteq))
      usage_start_date = parse_date(params.dig(:q, :cycles_created_at_gteq))
      usage_end_date   = parse_date(params.dig(:q, :cycles_created_at_lteq))

      # Construir a query base usando a view materializada
      base_query = CustomerDailyMetrics
        .for_store(current_store.id)
        .joins(:customer)
        .select("customers.*,
                 MIN(customer_daily_metrics.date) as first_cycle_date,
                 MAX(customer_daily_metrics.date) as last_cycle_date,
                 SUM(customer_daily_metrics.total_cycles) as cycles_count")

      # Aplicar filtros de data
      if start_date.present?
        base_query = base_query.where("customer_daily_metrics.date >= ?", start_date)
      end

      if end_date.present?
        base_query = base_query.where("customer_daily_metrics.date <= ?", end_date)
      end

      # Aplicar filtros de uso
      if usage_start_date.present? && usage_end_date.present?
        base_query = base_query.where("customer_daily_metrics.date BETWEEN ? AND ?",
                                    usage_start_date, usage_end_date)
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

      # Agrupar por customer
      base_query = base_query.group("customers.id, customers.name, customers.email, customers.phone_number")

      # Aplicar ordenação
      sort_param = params.dig(:q, :s)
      if sort_param.present? && ALLOWED_SORT_FIELDS.any? { |field| sort_param.include?(field) }
        # Tratar ordenação especial para campos calculados
        case sort_param
        when /first_cycle_date/
          base_query = base_query.order("MIN(customer_daily_metrics.date) #{sort_param.include?('desc') ? 'DESC' : 'ASC'}")
        when /last_cycle_date/
          base_query = base_query.order("MAX(customer_daily_metrics.date) #{sort_param.include?('desc') ? 'DESC' : 'ASC'}")
        when /cycles_count/
          base_query = base_query.order("SUM(customer_daily_metrics.total_cycles) #{sort_param.include?('desc') ? 'DESC' : 'ASC'}")
        else
          base_query = base_query.order(sort_param)
        end
      else
        base_query = base_query.order("MIN(customer_daily_metrics.date) DESC")
      end

      @customers = base_query.page(params[:page]).per(10)

      # Métricas para gráfico
      setup_metrics_data(start_date, end_date)

      respond_to do |format|
        format.html
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("customers_metrics", partial: "store_area/customers/metrics"),
            turbo_stream.update("customers_list", partial: "store_area/customers/list")
          ]
        end
      end
    end

    def show
      @customer = current_store.customers
        .joins("LEFT JOIN customer_daily_metrics ON customer_daily_metrics.customer_id = customers.id")
        .select("customers.*,
                 MIN(customer_daily_metrics.date) as first_cycle_date,
                 MAX(customer_daily_metrics.date) as last_cycle_date,
                 SUM(customer_daily_metrics.total_cycles) as cycles_count")
        .group("customers.id")
        .find(params[:id])

      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.update("modal", partial: "show") }
      end
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
      start_date_param = params.dig(:q, :first_cycle_date_gteq)
      end_date_param = params.dig(:q, :first_cycle_date_lteq)
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

    def setup_metrics_data(start_date, end_date)
      # Total de clientes e distribuição por status
      query = current_store.customers

      # Aplicar filtros de busca
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
          query = query.where(search_conditions.join(" AND "), *search_params)
        end
      end

      if start_date.present? && end_date.present?
        query = query.where("EXISTS (
          SELECT 1 FROM cycles
          WHERE cycles.customer_id = customers.id
          AND cycles.store_id = ?
          AND cycles.created_at BETWEEN ? AND ?
        )", current_store.id, start_date, end_date)
      end

      @total_customers = query.count
      @active_customers = query.where(is_active: true).count
      @inactive_customers = @total_customers - @active_customers

      # Usar a view materializada para os dados diários
      stats = CustomerDailyMetrics.for_store(current_store.id)

      # Aplicar filtros de busca na view materializada
      if params[:q].present?
        if params.dig(:q, :name_cont).present? || params.dig(:q, :email_cont).present? || params.dig(:q, :phone_number_cont).present?
          stats = stats.joins(:customer).where(search_conditions.join(" AND "), *search_params)
        end
      end

      if start_date.present? && end_date.present?
        stats = stats.between_dates(start_date, end_date)
      end

      # Dados para o gráfico de atividade (separado por tipo de ciclo)
      @activity_data = {
        total: stats.group(:date).sum(:total_cycles).sort_by { |date, _| date },
        dryer: stats.group(:date).sum(:dryer_cycles).sort_by { |date, _| date },
        washer: stats.group(:date).sum(:washer_cycles).sort_by { |date, _| date }
      }

      # Determinar o agrupamento baseado no intervalo de datas
      date_range = if start_date.present? && end_date.present?
                    (end_date - start_date).to_i
      else
                    # Se não houver filtro de data, usar o intervalo desde o primeiro ciclo
                    first_cycle_date = current_store.cycles.minimum(:created_at)
                    if first_cycle_date
                      (Date.current - first_cycle_date.to_date).to_i
                    else
                      0
                    end
      end

      # Agrupar por dia, mês ou ano dependendo do intervalo
      if date_range > 365 # Mais de 1 ano
        @customers_by_day = query
          .joins(:cycles)
          .group("DATE_TRUNC('month', cycles.created_at)")
          .count
          .sort_by { |date, _| date }
          .map { |date, count| [ date.strftime("%Y-%m"), count ] }
      elsif date_range > 30 # Mais de 1 mês
        @customers_by_day = query
          .joins(:cycles)
          .group("DATE(cycles.created_at)")
          .count
          .sort_by { |date, _| date }
          .map { |date, count| [ date.strftime("%Y-%m-%d"), count ] }
      else # Menos de 1 mês
        @customers_by_day = query
          .joins(:cycles)
          .group("DATE(cycles.created_at)")
          .count
          .sort_by { |date, _| date }
          .map { |date, count| [ date.strftime("%Y-%m-%d"), count ] }
      end
    end
  end
end
