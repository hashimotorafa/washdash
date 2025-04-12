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
                locals: { income_statement: @income_statement, costs: @income_statement.reload.costs }
              )
            }
          else
            format.turbo_stream {
              render turbo_stream: turbo_stream.update(
                "new_cost_form",
                partial: "store_area/financial/costs/form",
                locals: { income_statement: @income_statement, cost: @cost }
              )
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
        respond_to do |format|
          if @cost.update(cost_params)
            format.turbo_stream {
              render turbo_stream: turbo_stream.update(
                "costs-index",
                partial: "store_area/financial/costs/index",
                locals: { income_statement: @income_statement, costs: @income_statement.reload.costs }
              )
            }
          end
        end
      end

      def destroy
        @cost.destroy
        respond_to do |format|
          format.turbo_stream {
            render turbo_stream: turbo_stream.update(
              "costs-index",
              partial: "store_area/financial/costs/index",
              locals: { income_statement: @income_statement, costs: @income_statement.reload.costs }
            )
          }
        end
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
