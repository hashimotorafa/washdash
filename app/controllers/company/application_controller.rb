module Company
  class ApplicationController < ActionController::Base
    layout "layouts/company/application"
    protect_from_forgery with: :exception

    before_action :authenticate_user!
  end
end
