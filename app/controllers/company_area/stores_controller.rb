module CompanyArea
  class StoresController < CompanyArea::ApplicationController
    before_action :set_store, only: [ :edit, :update ]
    def index
      @stores = current_company.stores
    end

    def edit
    end

    def update
      if @store.update(store_params)
        redirect_to company_area_stores_path, notice: 'Loja atualizada com sucesso'
      else
        render :edit
      end
    end

    private

    def store_params
      params.require(:store).permit(:name, :area_code, :external_id)
    end

    def set_store
      @store = current_company.stores.find(params[:id])
    end
  end
end
