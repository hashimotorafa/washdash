module Admin
  class StoresController < Admin::ApplicationController
    before_action :set_store, only: [ :show, :edit, :update, :destroy ]
    before_action :set_companies, only: [ :new, :create, :edit, :update ]

    def index
      @stores = Store.includes(:company).ordered
    end

    def show
    end

    def new
      @store = Store.new
    end

    def edit
    end

    def create
      @store = Store.new(store_params)

      if @store.save
        redirect_to admin_store_path(@store), notice: "Loja criada com sucesso."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @store.update(store_params)
        redirect_to admin_store_path(@store), notice: "Loja atualizada com sucesso."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @store.destroy
      redirect_to admin_stores_path, notice: "Loja removida com sucesso.", status: :see_other
    end

    private

    def set_store
      @store = Store.find(params[:id])
    end

    def set_companies
      @companies = Company.active.order(:name)
    end

    def store_params
      params.require(:store).permit(:name, :area_code, :external_id, :company_id, :started_at)
    end
  end
end
