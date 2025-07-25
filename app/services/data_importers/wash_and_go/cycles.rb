require "roo"

# Esta classe popula as tabelas customers e cycles com base no EXCEL de extrato da Wash&Go
module DataImporters
  module WashAndGo
    class Cycles
      CYCLES_HEADER     = %w[id email machine_type machine_number status price created_at description]
      CUSTOMER_HEADER   = %w[email name phone_number created_at]
      SKIP_SHEET_HEADER = 2

      def initialize(store, xslx_file_path: nil)
        @xlsx_file          = Roo::Spreadsheet.open(xslx_file_path, extension: :xlsx)
        @customers          = []
        @customer_stores    = {}
        @cycles_attributes  = []
        @store              = store
      end

      def sync_tables
        @xlsx_file.each_row_streaming(offset: SKIP_SHEET_HEADER) do |row|
          next if row[0].value == "ID Utiliza\u00E7\u00E3o" || row[0].value == "TOTAL:"

          if customer_row?(row)
            @customers << find_or_initialize_customer(customer_data(row))
          else
            cycle_data = cycle_data(row)
            customer = @customers.last

            unless customer.persisted?
              Rails.logger.info(customer.errors.full_messages)
              customer.save
            end

            customer_store = find_or_create_customer_store(customer)
            customer_store.first_visit_date = cycle_data[:created_at] if customer_store.first_visit_date.nil? || customer_store.first_visit_date > cycle_data[:created_at]
            customer_store.save if customer_store.changed?

            @cycles_attributes << cycle_data.merge({ customer_id: customer.id, store_id: @store.id })
          end
        end
        Cycle.upsert_all(@cycles_attributes, unique_by: :external_id)
      end

      private

      def find_or_initialize_customer(customer_data)
        @customer ||= {}
        @customer[customer_data[:email]] ||= Customer.find_or_initialize_by(email: customer_data[:email]).tap do |customer|
          customer.name = customer_data[:name]
          customer.area_code = customer_data[:area_code]
          customer.phone_number = customer_data[:phone_number]
          customer.document_number = customer_data[:document_number]
          customer.is_active ||= true
          customer.save if customer.changed?
        end
      end

      def find_or_create_customer_store(customer)
        return @customer_stores[customer.id] if @customer_stores[customer.id]

        customer.customer_stores.find_by(store: @store) || customer.customer_stores.create(store: @store)
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

      def cycle_data(row)
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
    end
  end
end
