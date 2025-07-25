module StoreArea
  module Financial
    class IncomeStatementsController < StoreArea::ApplicationController
      before_action :income_statement, only: [ :show, :edit, :update, :destroy, :import_transactions ]

      def index
        @income_statements = IncomeStatement.where(store: current_store).order(year: :asc, month: :asc)
      end

      def new
        @income_statement = IncomeStatement.new
      end

      def create
        @income_statement = @current_store.income_statements.new(income_statement_params)
        @income_statement.created_at = @income_statement.month_year
        if @income_statement.save
          redirect_to store_area_financial_income_statement_path(@current_store.id, @income_statement.id), notice: "DRE criada com sucesso"
        else
          render :new
        end
      end

      def import_transactions
        if params[:file].present?
          # Create a unique filename to avoid conflicts
          filename = "income_statement#{@current_store.id}_#{Time.now.to_i}_#{params[:file].original_filename}"
          file_path = Rails.root.join("tmp", filename)

          # Save the uploaded file to the tmp directory
          File.open(file_path, "wb") do |file|
            file.write(params[:file].read)
          end

          # Call the sync_tables method with the saved file path
          DataImporters::WashAndGo::FinancialStatement.new(@current_store, xslx_file_path: file_path).sync_tables
          TransactionMonthlyMetrics.refresh
          # Clean up the temporary file after processing
          File.delete(file_path) if File.exist?(file_path)

          redirect_to store_area_financial_income_statement_path(@current_store.id, @income_statement.id), notice: "Importação concluída com sucesso"
        else
          redirect_to store_area_financial_income_statement_path(@current_store.id, @income_statement.id), alert: "Por favor, selecione um arquivo para importar"
        end
      end

      def show
      end

      def edit
      end

      def update
      end

      def destroy
      end

      private

      def income_statement_params
        params.require(:income_statement).permit(:year, :month)
      end

      def income_statement
        @income_statement ||= IncomeStatement.find(params[:id])
      end
    end
  end
end
