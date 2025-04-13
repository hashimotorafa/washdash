module StoreArea
  class CustomersController < StoreArea::ApplicationController
    before_action :set_customer, only: [ :show ]
    helper_method :period_text

    def index
      @q = current_store.customers.ransack(params[:q])

      start_date = params.dig(:q, :first_cycle_date_gteq) || 30.days.ago
      end_date = params.dig(:q, :first_cycle_date_lteq) || Time.current

      # Construir a query base
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
                             AND cycles.created_at BETWEEN '#{start_date}' AND '#{end_date}') as cycles_count")

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

    def period_text
      start_date_param = params.dig(:q, :first_cycle_date_gteq)
      end_date_param = params.dig(:q, :first_cycle_date_lteq)

      if start_date_param.blank? && end_date_param.blank?
        "Todos os períodos"
      elsif start_date_param.present? && end_date_param.present?
        "De #{start_date_param.to_date.strftime('%d/%m/%Y')} a #{end_date_param.to_date.strftime('%d/%m/%Y')}"
      elsif start_date_param.present?
        "A partir de #{start_date_param.to_date.strftime('%d/%m/%Y')}"
      else
        "Até #{end_date_param.to_date.strftime('%d/%m/%Y')}"
      end
    end
  end
end
