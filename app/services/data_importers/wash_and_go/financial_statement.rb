require "roo"

# Esta classe popula as tabelas customers e cycles com base no EXCEL de extrato da Wash&Go
module DataImporters
  module WashAndGo
    class FinancialStatement
      CYCLES_HEADER     = %w[id email machine_type machine_number status price created_at description]
      CUSTOMER_HEADER   = %w[email name phone_number created_at]
      SKIP_SHEET_HEADER = 2
      PAYMENT_METHODS   = {
        "CARTÃO" => :card,
        "ESTORNO CARTÃO" => :card_reversal,
        "PIX" => :pix,
        "ESTORNO PIX" => :pix_reversal,
        "VOUCHER" => :voucher
      }

      def initialize(store, xslx_file_path: nil)
        @xlsx_file          = Roo::Spreadsheet.open(xslx_file_path, extension: :xlsx)
        @transaction_attributes  = []
        @store              = store
      end

      def sync_tables
        @xlsx_file.each_row_streaming(offset: SKIP_SHEET_HEADER) do |row|
          next if row[1].value == "TOTAL:"

          @transaction_attributes << transaction_data(row)
        end
        Transaction.upsert_all(@transaction_attributes, unique_by: :transaction_id)
      end

      private

      def find_customer(row)
        @customer ||= {}

        email = row[1].value.include?("_excluido") ? row[1].value.split("_excluido").first : row[1].value
        @customer[row[1].value] ||= Customer.find_by!(email: email)
      rescue ActiveRecord::RecordNotFound => _e
        Rails.logger.error("Customer not found: #{email}")
        @customer[row[1].value] ||= Customer.create(email: email, name: "Desconhecido", phone_number: "Desconhecido", area_code: "Desconhecido")
      end

      def transaction_data(row)
        {
          customer_id:        find_customer(row).id,
          amount:             row[2].value,
          payment_method_tax: row[3].value,
          sub_acquirer:       row[4].value,
          amount_before_tax:  row[5].value,
          fup:                row[6].value,
          royalties:          row[7].value,
          amount_receivable:  row[8].value,
          created_at:         row[9].value.to_datetime,
          updated_at:         row[9].value.to_datetime,
          payment_method:     PAYMENT_METHODS[row[10].value],
          transaction_id:     row[11].value,
          store_id:           @store.id
        }
      end
    end
  end
end
