class RefreshCustomerCyclesDailyStatsJob < ApplicationJob
  queue_as :default

  def perform
    CustomerCyclesDailyStat.refresh
  end
end
