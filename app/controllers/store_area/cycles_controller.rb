module StoreArea
  class CyclesController < StoreArea::ApplicationController
    before_action :set_cycle, only: [ :show ]
    helper_method :period_text

    def index
      # Main query for listing cycles with customer includes and ordering
      @q = @current_store.cycles.includes(:customer).ransack(params[:q])
      @cycles = @q.result.order(created_at: :desc).page(params[:page])

      # Separate query for metrics without includes and ordering
      metrics_params = params[:q].dup if params[:q].present?
      metrics_params&.delete(:s) # Remove sorting parameters
      metrics_q = @current_store.cycles.ransack(metrics_params)
      metrics_scope = metrics_q.result

      # Get date range from search params or default to last 30 days
      start_date_param = params.dig(:q, :created_at_gteq)
      end_date_param = params.dig(:q, :created_at_lteq)

      @start_date = start_date_param.present? ? start_date_param.to_date : 30.days.ago.beginning_of_day
      @end_date = end_date_param.present? ? end_date_param.to_date : Time.current

      # Apply date filter to metrics scope
      if start_date_param.present? || end_date_param.present?
        metrics_scope = metrics_scope.where(created_at: @start_date..@end_date)
      end

      # Calculate metrics
      @total_cycles = metrics_scope.count
      @canceled_cycles = metrics_scope.where(status: "Estornado").count
      @completed_cycles = metrics_scope.where(status: "Efetivado").count

      @cycles_by_status = metrics_scope
        .group(:status)
        .count

      @cycles_by_day = metrics_scope
        .group_by_day(:created_at)
        .count

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

    def import_cycles
      if params[:file].present?
        # Create a unique filename to avoid conflicts
        filename = "cycles_report_#{@current_store.id}_#{Time.now.to_i}_#{params[:file].original_filename}"
        file_path = Rails.root.join("tmp", filename)

        # Save the uploaded file to the tmp directory
        File.open(file_path, "wb") do |file|
          file.write(params[:file].read)
        end

        DataImporters::WashAndGo::Cycles.new(@current_store, xslx_file_path: file_path).sync_tables
        CustomerMonthlyMetrics.refresh

        redirect_to store_area_cycles_path(@current_store), notice: "Ciclos importados com sucesso!"
      else
        redirect_to store_area_cycles_path(@current_store), alert: "Por favor, selecione um arquivo para importar."
      end
    end

    private

    def set_cycle
      @cycle = @current_store.cycles.find(params[:id])
    end

    def period_text
      start_date_param = params.dig(:q, :created_at_gteq)
      end_date_param = params.dig(:q, :created_at_lteq)

      if start_date_param.blank? && end_date_param.blank?
        "Todos os períodos"
      elsif start_date_param.present? && end_date_param.present?
        "De #{@start_date.strftime('%d/%m/%Y')} a #{@end_date.strftime('%d/%m/%Y')}"
      elsif start_date_param.present?
        "A partir de #{@start_date.strftime('%d/%m/%Y')}"
      else
        "Até #{@end_date.strftime('%d/%m/%Y')}"
      end
    end
  end
end
