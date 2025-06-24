module CompanyArea
  class ApplicationController < ActionController::Base
    layout "layouts/company/application"
    protect_from_forgery with: :exception

    before_action :authenticate_user!

    def current_company
      if current_user.admin
        @current_company ||= Company.find(params[:company_id])
      else
        @current_company ||= current_user.company
      end
    end
  end
end
