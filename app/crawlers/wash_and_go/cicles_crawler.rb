module WashAndGo
  class CiclesCrawler < WashAndGo::BaseCrawler
    DOWNLOAD_FILE_FOLDER_PATH  = "./tmp/files/"
    class << self
      def run(store, email, password)
        @driver = setup_driver
        login(email, password)
        redirect_to_cicles_page(store)
        filter_cicles_by_date_range(store)
        download
        rename_file(store)
        puts "Downloaded"
      rescue StandardError => e
        puts e
      ensure
        @driver.quit
      end

      private

      def redirect_to_cicles_page(store)
        @driver.get("#{ WashAndGo::BaseCrawler::URL}/admin/extratocondominio/#{store.external_id}")
        wait_until { page_loaded }
        puts "Cicles - Page Loaded"
      end

      def filter_cicles_by_date_range(store)
        last_cicles = store.cicles.last
        puts "Cicles - Updating Date Inputs"
        start_date_input = @driver.find_element(id: "inicioEx")
        end_date_input   = @driver.find_element(id: "fimEx")

        start_date_input.clear
        end_date_input.clear

        start_date, end_date = date_range(store, last_cicles)

        start_date_input.send_keys(start_date)
        end_date_input.send_keys(end_date)

        @driver.find_element(class_name: "ls-box-filter").click()

        puts "Cicles - Filtering Results for start date (#{start_date}) and end date(#{end_date})"
        @driver.find_element(id: "btnextratocondominio").click()

        puts "Waiting Filtered Results #{Time.now}"
      end

      # atualizar data de criação da loja
      def date_range(store, last_cicles)
        start_date = (last_cicles&.created_at&.strftime("%d/%m/%Y") || store.started_at.strftime("%d/%m/%Y"))

        # melhorar para pegar de 6 em 6 meses se o Date.today for muito distante
        if start_date.to_date < 6.months.ago.to_date
          end_date = 6.months.ago.to_date.strftime("%d/%m/%Y")
        else
          end_date = Date.today.strftime("%d/%m/%Y")
        end

        [ start_date, end_date ]
      end

      def download
        @driver.find_element(class_name: "ls-float-right").click()
        puts "Downloading Results #{Time.now}"
        sleep 10
      end

      def rename_file(store)
        original_file_name = Dir["./tmp/files/Extrato*.xlsx"].first

        File.rename(
          File.join(original_file_name),
          File.join(DOWNLOAD_FILE_FOLDER_PATH, "extrato_#{store.external_id}.xlsx")
        )
      end
    end
  end
end
