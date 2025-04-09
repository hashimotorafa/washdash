namespace :cycles do
  task log: :environment do
    File.open("out-#{DateTime.now}.txt", "w") { |f| f.write(DateTime.now) }
  end

  task fetch: :environment do
    Company.all.each do |company|
      next unless company.external_access&.has_credentials?

      company.stores.each do |store|
        file_name = "extrato_#{store.external_id}.xlsx"
        file_path = "#{Rails.root}/tmp/files/#{file_name}"

        puts "Running Crawler"

        WashAndGo::CyclesCrawler.run(
          store,
          company.external_access.email,
          company.external_access.password
        )

        if File.exist?(file_path)
          puts "Running Data Importer"
          cycles_importer = DataImporters::WashAndGo::Cycles.new(
            store,
            xslx_file_path: file_path
          )

          cycles_importer.sync_tables
          puts "Refreshing Customer Montly Metrics Materialized View"
          CustomerMonthlyMetrics.refresh
          puts "Done"
        else
          raise StandardError, "cycles Fetch Failed: File at #{file_path} not found"
        end
      end
    end
  end
end
