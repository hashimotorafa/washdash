module StoreArea
  class CustomersController < StoreArea::ApplicationController
    before_action :set_customer, only: [ :show ]
    helper_method :period_text

    def index
      @q = current_store.customers.ransack(params[:q])

      # Tratamento seguro das datas
      start_date = parse_date(params.dig(:q, :first_cycle_date_gteq))
      end_date = parse_date(params.dig(:q, :first_cycle_date_lteq))
      usage_start_date = parse_date(params.dig(:q, :cycles_created_at_gteq))
      usage_end_date = parse_date(params.dig(:q, :cycles_created_at_lteq))

      # Construir a query base com a data do primeiro ciclo
      base_query = @q.result(distinct: true)
                    .select("customers.*,
                            (SELECT MIN(cycles.created_at)
                             FROM cycles
                             WHERE cycles.customer_id = customers.id
                             AND cycles.store_id = #{current_store.id}) as first_cycle_date,
                            (SELECT MAX(cycles.created_at)
                             FROM cycles
                             WHERE cycles.customer_id = customers.id
                             AND cycles.store_id = #{current_store.id}) as last_cycle_date,
                            (SELECT COUNT(*)
                             FROM cycles
                             WHERE cycles.customer_id = customers.id
                             AND cycles.store_id = #{current_store.id}
                             #{usage_start_date.present? && usage_end_date.present? ? "AND cycles.created_at BETWEEN '#{usage_start_date}' AND '#{usage_end_date}'" : ""}) as cycles_count")

      # Aplicar filtro de data de cadastro (primeiro ciclo) se fornecido
      if start_date.present? || end_date.present?
        base_query = base_query.where("EXISTS (
          SELECT 1 FROM cycles
          WHERE cycles.customer_id = customers.id
          AND cycles.store_id = #{current_store.id}
          #{start_date.present? ? "AND cycles.created_at >= '#{start_date}'" : ""}
          #{end_date.present? ? "AND cycles.created_at <= '#{end_date}'" : ""}
        )")
      end

      # Aplicar filtro de período de uso se fornecido
      if usage_start_date.present? && usage_end_date.present?
        base_query = base_query.where("EXISTS (
          SELECT 1 FROM cycles
          WHERE cycles.customer_id = customers.id
          AND cycles.store_id = #{current_store.id}
          AND cycles.created_at BETWEEN '#{usage_start_date}' AND '#{usage_end_date}'
        )")
      end

      # Aplicar ordenação
      if params.dig(:q, :s).present?
        sort_param = params.dig(:q, :s)
        if sort_param.include?("cycles_count")
          @customers = base_query.order(sort_param)
        else
          @customers = base_query.order(sort_param)
        end
      else
        @customers = base_query.order("first_cycle_date DESC")
      end

      @customers = @customers.page(params[:page]).per(10)

      # Dados para os gráficos
      setup_metrics_data(start_date, end_date)

      respond_to do |format|
        format.html
        format.turbo_stream
      end
    end

    def show
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.update("modal", partial: "show") }
      end
    end

    private

    def set_customer
      @customer = @current_store.customers.find(params[:id])
    end

    def parse_date(date_string)
      return nil if date_string.blank?
      begin
        Date.parse(date_string)
      rescue ArgumentError
        nil
      end
    end

    def period_text
      start_date_param = params.dig(:q, :first_cycle_date_gteq)
      end_date_param = params.dig(:q, :first_cycle_date_lteq)
      usage_start_param = params.dig(:q, :cycles_created_at_gteq)
      usage_end_param = params.dig(:q, :cycles_created_at_lteq)

      if start_date_param.blank? && end_date_param.blank? && usage_start_param.blank? && usage_end_param.blank?
        "Todos os períodos"
      else
        text = []
        if start_date_param.present? || end_date_param.present?
          text << "Primeiro ciclo #{start_date_param.present? ? "a partir de #{start_date_param.to_date.strftime('%d/%m/%Y')}" : ""} #{end_date_param.present? ? "até #{end_date_param.to_date.strftime('%d/%m/%Y')}" : ""}"
        end
        if usage_start_param.present? || usage_end_param.present?
          text << "Utilizaram #{usage_start_param.present? ? "a partir de #{usage_start_param.to_date.strftime('%d/%m/%Y')}" : ""} #{usage_end_param.present? ? "até #{usage_end_param.to_date.strftime('%d/%m/%Y')}" : ""}"
        end
        text.join(" e ")
      end
    end

    def setup_metrics_data(start_date, end_date)
      # Total de clientes e distribuição por status
      @total_customers = current_store.customers.count
      @active_customers = current_store.customers.where(is_active: true).count
      @inactive_customers = @total_customers - @active_customers

      # Clientes por dia (baseado no primeiro ciclo)
      query = current_store.customers
      if start_date.present? && end_date.present?
        query = query.where("EXISTS (
          SELECT 1 FROM cycles
          WHERE cycles.customer_id = customers.id
          AND cycles.store_id = #{current_store.id}
          AND cycles.created_at BETWEEN ? AND ?
        )", start_date, end_date)
      end

      # Agrupar por data do primeiro ciclo
      @customers_by_day = query.joins("LEFT JOIN (
        SELECT customer_id, MIN(created_at) as first_cycle_date
        FROM cycles
        WHERE store_id = #{current_store.id}
        GROUP BY customer_id
      ) first_cycles ON first_cycles.customer_id = customers.id")
      .group("DATE(first_cycles.first_cycle_date)")
      .count

      # Distribuição de ciclos
      query = current_store.customers.joins(:cycles)
      if start_date.present? && end_date.present?
        query = query.where("cycles.created_at BETWEEN ? AND ?", start_date, end_date)
      end
      @cycles_distribution = query.group("customers.id")
                                .count("cycles.id")
                                .group_by { |_, count| count }
                                .transform_values(&:count)
                                .sort_by { |count, _| count }
                                .to_h

      # Atividade dos clientes (ciclos por dia)
      query = current_store.cycles
      if start_date.present? && end_date.present?
        query = query.where("cycles.created_at BETWEEN ? AND ?", start_date, end_date)
      end
      @activity_data = query.group_by_day("cycles.created_at").count
    end
  end
end
