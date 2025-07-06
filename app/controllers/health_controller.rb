class HealthController < ActionController::API
  def up
    head :ok
  end
end
