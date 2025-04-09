class CreateIncomeStatement < ActiveRecord::Migration[7.2]
  def change
    create_table :income_statements do |t|
      t.references :store, null: false, foreign_key: true
      t.integer :year
      t.integer :month
      t.decimal :net_profit, precision: 10, scale: 2
      t.timestamps
    end
  end
end
