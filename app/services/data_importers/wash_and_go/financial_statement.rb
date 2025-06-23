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
        return @customer[row[1].value] if @customer[row[1].value].present?

        email = row[1].value.include?("_excluido") ? row[1].value.split("_excluido").first : row[1].value
        is_active = !row[1].value.include?("_excluido")

        @customer[row[1].value] = Customer.find_by!(email: email).tap do |customer|
          customer.update(is_active: is_active) if customer.is_active != is_active
        end
        @customer[row[1].value]
      rescue ActiveRecord::RecordNotFound => _e
        Rails.logger.error("Customer not found: #{email}")
        @customer[row[1].value] ||= Customer.create(
          email: email,
          name: "Desconhecido",
          phone_number: "Desconhecido",
          area_code: "Desconhecido",
          is_active: is_active
        )
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
          transaction_id:     set_transaction_id(row),
          store_id:           @store.id
        }
      end

      def set_transaction_id(row)
        return row[11].value if row[11].present?
        if @transaction_attributes.last.nil?
          SecureRandom.uuid
        elsif @transaction_attributes.last[:transaction_id].to_s.include?("_")
          base_transaction_id, last_counter = @transaction_attributes.last[:transaction_id].split("_")

          "#{base_transaction_id}_#{last_counter.to_i + 1}"
        else
          "#{@transaction_attributes.last[:transaction_id]}_1"
        end
      end
    end
  end
end
