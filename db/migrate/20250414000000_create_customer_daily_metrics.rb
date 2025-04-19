class CreateCustomerDailyMetrics < ActiveRecord::Migration[7.1]
  def up
    execute <<-SQL
      CREATE MATERIALIZED VIEW customer_daily_metrics AS
      SELECT#{' '}
        store_id,
        customer_id,
        DATE(created_at) as date,
        COUNT(*)::integer as total_cycles,
        COUNT(CASE WHEN machine_type = 'Secadora' THEN 1 END)::integer as dryer_cycles,
        COUNT(CASE WHEN machine_type = 'Lavadora' THEN 1 END)::integer as washer_cycles
      FROM cycles
      GROUP BY store_id, customer_id, DATE(created_at)
      ORDER BY date DESC;
    SQL

    # Adicionar índices para melhor performance
    execute "CREATE INDEX idx_customer_daily_metrics_store_id ON customer_daily_metrics (store_id);"
    execute "CREATE INDEX idx_customer_daily_metrics_customer_id ON customer_daily_metrics (customer_id);"
  end

  def down
    execute "DROP MATERIALIZED VIEW IF EXISTS customer_daily_metrics;"
  end
end
