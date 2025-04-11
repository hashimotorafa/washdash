module StoreArea
  module Financial
    class CostsController < StoreArea::ApplicationController
      before_action :income_statement, :current_store
      before_action :cost, only: [ :edit, :update, :destroy, :show ]

      def new
        render partial: "new", locals: { income_statement: @income_statement, cost: Cost.new }
      end

      def create
        @cost = @income_statement.costs.build(cost_params)
        @cost.store = @income_statement.store

        respond_to do |format|
          if @cost.save
            format.turbo_stream {
              render turbo_stream: turbo_stream.update(
                "costs-index",
                partial: "store_area/financial/costs/index",
                locals: { income_statement: @income_statement, costs: @income_statement.costs }
              )
            }
            format.html {
              redirect_to store_area_financial_income_statement_path(@income_statement.store_id, @income_statement),
                          notice: "Custo adicionado com sucesso"
            }
          else
            format.turbo_stream {
              render turbo_stream: turbo_stream.update(
                "new_cost_form",
                partial: "store_area/financial/costs/form",
                locals: { income_statement: @income_statement, cost: @cost }
              )
            }
            format.html {
              redirect_to store_area_financial_income_statement_path(@income_statement.store_id, @income_statement),
                          alert: "Erro ao adicionar custo: #{@cost.errors.full_messages.join(', ')}"
            }
          end
        end
      end

      def show
        render partial: "show", locals: { cost: @cost }
      end

      def edit
        render partial: "edit", locals: { cost: @cost }
      end

      def update
        if @cost.update(cost_params)
          redirect_to store_area_financial_income_statement_path(@income_statement.store_id, @income_statement),
                      notice: "Custo atualizado com sucesso"
        else
          render :edit
        end
      end

      def destroy
        @cost.destroy
        redirect_to store_area_financial_income_statement_path(@income_statement.store_id, @income_statement),
                    notice: "Custo excluído com sucesso"
      end

      private

      def income_statement
        @income_statement ||= IncomeStatement.find(params[:income_statement_id])
      end

      def cost
        @cost ||= @income_statement.costs.find(params[:id])
      end

      def cost_params
        params.require(:cost).permit(
          :description,
          :amount,
          :category,
          :payment_method,
          :payment_status,
          :due_date,
          :name
        )
      end
    end
  end
end
