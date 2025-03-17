require "roo"

# Esta classe popula as tabelas customers e cicles com base no EXCEL de extrato da Wash&Go
module DataImporters
  module WashAndGo
    class FinancialStatement
      CICLES_HEADER     = %w[id email machine_type machine_number status price created_at description]
      CUSTOMER_HEADER   = %w[email name phone_number created_at]
      SKIP_SHEET_HEADER = 2

      def initialize(store, xslx_file_path: nil)
        @xlsx_file          = Roo::Spreadsheet.open(xslx_file_path, extension: :xlsx)
        @customers          = []
        @cicles_attributes  = []
        @store              = store
      end

      def sync_tables
        @xlsx_file.each_row_streaming(offset: SKIP_SHEET_HEADER) do |row|
          next if row[0].value == "ID Utiliza\u00E7\u00E3o" || row[0].value == "TOTAL:"

          if customer_row?(row)
            @customers << find_or_initialize_customer(customer_data(row))
          else
            cicle_data = cicle_data(row)
            unless @customers.last.persisted?
              create_customer(@customers.last, cicle_data[:created_at])
              @customers.last.reload
            end
            @cicles_attributes << cicle_data.merge({ customer_id: @customers.last.id, store_id:  @store.id })
          end
        end
        Cicle.upsert_all(@cicles_attributes, unique_by: :external_id)
      end

      private

      def find_or_initialize_customer(customer_data)
        Customer.find_or_initialize_by(email: customer_data[:email]) do |customer|
          customer.name = customer_data[:name]
          customer.area_code = customer_data[:area_code]
          customer.phone_number = customer_data[:phone_number]
          customer.document_number = customer_data[:document_number]
        end
      end

      def customer_row?(row)
        row[0].value.class == String && row[0].value.include?("@")
      end

      # find or create by
      def customer_data(row)
        { email: row[0].value, name: row[1].value, document_number: row[2].value, area_code: get_area_code(row[3].value), phone_number: row[3].value }
      end

      def get_area_code(phone_number)
        phone_number.match(/\(\d*\)/)[0][1..2]
      rescue NoMethodError => e
        Rails.logger.error("Failed to get area code from #{phone_number}")
        "00"
      end

      def cicle_data(row)
        {
          external_id:    row[0].value,
          machine_type:   row[3].value.split("-").last.strip[0] == "L" ? "Lavadora" : "Secadora",
          machine_number: row[3].value.split("-").last.strip[1],
          status:         row[4].value,
          price:          row[5].value,
          description:    row[6].value,
          created_at:     "#{row[1]} #{row[2]}".to_datetime
        }
      end

      def create_customer(customer, created_at)
        customer.created_at = created_at
        customer.updated_at = created_at
        customer.save
      end
    end
  end
end
