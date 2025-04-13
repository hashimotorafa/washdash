module StoreArea
  class CyclesController < StoreArea::ApplicationController
    before_action :set_cycle, only: [ :show ]

    def index
      @q = @current_store.cycles.includes(:customer).ransack(params[:q])
      @cycles = @q.result.order(created_at: :desc).page(params[:page])

      # Prepare data for charts
      @cycles_by_status = @current_store.cycles
        .where(created_at: 30.days.ago.beginning_of_day..Time.current)
        .group(:status)
        .count

      @cycles_by_day = @current_store.cycles
        .where(created_at: 30.days.ago.beginning_of_day..Time.current)
        .group_by_day(:created_at)
        .count
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
  end
end
