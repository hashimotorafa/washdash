module Company
  class ApplicationController < ActionController::Base
    layout "layouts/company/application"
    protect_from_forgery with: :exception
  end
end
