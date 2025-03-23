class CreateTransactionsMonthlyMetricsMaterializedView < ActiveRecord::Migration[7.2]
  def up
    execute <<-SQL
      CREATE MATERIALIZED VIEW transaction_monthly_metrics AS
      SELECT
          t.customer_id,
          cu.area_code,
          t.store_id,
          DATE_TRUNC('month', t.created_at) AS month,
          COUNT(CASE WHEN t.payment_method = 1 THEN 1 END) AS card,
          COUNT(CASE WHEN t.payment_method = 2 THEN 1 END) AS card_reversal,
          COUNT(CASE WHEN t.payment_method = 3 THEN 1 END) AS pix,
          COUNT(CASE WHEN t.payment_method = 4 THEN 1 END) AS pix_reversal,
          COUNT(CASE WHEN t.payment_method = 5 THEN 1 END) AS voucher,
          COUNT(*) AS total_transactions,
          ROUND(SUM(CAST(t.amount AS NUMERIC)), 2) AS total_spent,
          ROUND(SUM(CAST(t.amount_receivable AS NUMERIC)), 2) AS total_receivable,
          ROUND(SUM(CAST(t.amount_before_tax AS NUMERIC)), 2) AS total_before_tax,
          ROUND(SUM(CAST(t.royalties AS NUMERIC)), 2) AS total_royalties,
          ROUND(SUM(CAST(t.fup AS NUMERIC)), 2) AS total_fup,
          ROUND(SUM(CAST(t.payment_method_tax AS NUMERIC)), 2) AS total_payment_method_tax
      FROM
          transactions t
      JOIN
          customers cu ON t.customer_id = cu.id
      GROUP BY
          t.customer_id, cu.area_code, t.store_id, DATE_TRUNC('month', t.created_at);
    SQL

    # Adicionando índices
    execute <<-SQL
      CREATE INDEX index_transaction_monthly_metrics_on_customer_id ON transaction_monthly_metrics (customer_id);
      CREATE INDEX index_transaction_monthly_metrics_on_store_id ON transaction_monthly_metrics (store_id);
    SQL
  end

  def down
    execute <<-SQL
      DROP MATERIALIZED VIEW IF EXISTS transaction_monthly_metrics;
    SQL
  end
end
