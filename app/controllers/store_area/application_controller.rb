module StoreArea
  class ApplicationController < ActionController::Base
    layout "layouts/store/application"
    protect_from_forgery with: :exception

    before_action :authenticate_user!
    before_action :current_store

    private

    def current_store
      @current_store ||= current_user.company.stores.find(params[:store_id])
    end
  end
end
