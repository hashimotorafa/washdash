every 1.day, at: "00:00" do
  runner "RefreshCustomerCyclesDailyStatsJob.perform_later"
end
