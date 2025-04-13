module StoreArea
  class CustomersController < StoreArea::ApplicationController
    def index
      @customers = @current_store.customers
    end

    def show
      @customer = @current_store.customers.find(params[:id])
    end

    private
  end
end
