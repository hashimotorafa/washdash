module StoreArea
  class ApplicationController < ActionController::Base
    layout "layouts/store/application"
    protect_from_forgery with: :exception

    before_action :authenticate_user!
    before_action :current_store

    private

    def current_store
      if current_user.admin
        @current_store ||= Store.find(params[:store_id])
      else
        @current_store ||= current_user.company.stores.find(params[:store_id])
      end
    rescue ActiveRecord::RecordNotFound
      redirect_to company_stores_path(current_user.company), alert: "Loja não encontrada"
    end
  end
end
