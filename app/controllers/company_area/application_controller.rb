module CompanyArea
  class ApplicationController < ActionController::Base
    layout "layouts/company/application"
    protect_from_forgery with: :exception

    before_action :authenticate_user!

    def current_company
      @current_company ||= current_user.company
    end
  end
end
