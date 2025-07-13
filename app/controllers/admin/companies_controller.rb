module Admin
  class CompaniesController < Admin::ApplicationController
    before_action :set_company, except: [ :index, :new, :create ]

    def index
      @companies = Company.ordered
    end

    def show
    end

    def new
      @company = Company.new
    end

    def edit
    end

    def create
      @company = Company.new(company_params)

      if @company.save
        redirect_to admin_company_path(@company), notice: "Empresa criada com sucesso."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @company.update(company_params)
        redirect_to admin_company_path(@company), notice: "Empresa atualizada com sucesso."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @company.destroy
      redirect_to admin_companies_path, notice: "Empresa removida com sucesso.", status: :see_other
    end

    def switch
      session[:company_id] = @company.id
      redirect_to company_area_root_path
    end

    private

    def set_company
      @company = Company.find(params[:id])
    end

    def company_params
      params.require(:company).permit(
        :name,
        :city,
        :state,
        :status,
        :zip,
        :phone,
        :document_number
      )
    end
  end
end
