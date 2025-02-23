module Admin
  class ApplicationController < ActionController::Base
    layout "layouts/admin/application"

    protect_from_forgery with: :exception
    before_action :authenticate_user!

    before_action :check_admin

    private

    def check_admin
      redirect_back fallback_location: root_path unless current_user.admin?
    end
  end
end
