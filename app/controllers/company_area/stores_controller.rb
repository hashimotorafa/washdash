module CompanyArea
  class StoresController < CompanyArea::ApplicationController
    def index
      @stores = current_company.stores
    end
  end
end
