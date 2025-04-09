class CreateCustomerMonthlyMetricsMaterializedView < ActiveRecord::Migration[7.2]
  def up
    execute <<-SQL
      CREATE MATERIALIZED VIEW customer_monthly_metrics AS
      SELECT
          c.customer_id,
          cu.area_code,
          c.store_id,
          DATE_TRUNC('month', c.created_at) AS month,
          COUNT(DISTINCT DATE(c.created_at)) AS visits,
          COUNT(CASE WHEN c.machine_type = 'Lavadora' THEN 1 END) AS washer_cycles,
          COUNT(CASE WHEN c.machine_type = 'Secadora' THEN 1 END) AS dryer_cycles,
          COUNT(CASE WHEN c.status = 'Estornado' THEN 1 END)      AS canceled_cycles,
          COUNT(*) AS total_cycles,
          COUNT(*) / COUNT(DISTINCT DATE(c.created_at)) AS avg_cycles_per_visit,
          MAX(c.created_at) AS last_visit,
          MIN(c.created_at) AS first_visit,
          ROUND(SUM(CAST(c.price AS NUMERIC)), 2) AS total_spent,
          COUNT(DISTINCT DATE(c.created_at)) AS active_days
      FROM
          cycles c
      JOIN
          customers cu ON c.customer_id = cu.id
      GROUP BY
          c.customer_id, cu.area_code, c.store_id, DATE_TRUNC('month', c.created_at);
    SQL

    # Adicionando índices
    execute <<-SQL
      CREATE INDEX index_customer_monthly_metrics_on_customer_id ON customer_monthly_metrics (customer_id);
      CREATE INDEX index_customer_monthly_metrics_on_store_id ON customer_monthly_metrics (store_id);
    SQL
  end

  def down
    execute <<-SQL
      DROP MATERIALIZED VIEW IF EXISTS customer_monthly_metrics;
    SQL
  end
end
