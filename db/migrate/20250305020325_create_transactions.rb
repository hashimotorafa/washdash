class CreateTransactions < ActiveRecord::Migration[7.2]
  def change
    create_table :transactions do |t|
      t.decimal :amount, precision: 10, scale: 2
      t.decimal :payment_method_tax, precision: 10, scale: 2
      t.decimal :sub_acquirer, precision: 10, scale: 2
      t.decimal :amount_before_tax, precision: 10, scale: 2
      t.decimal :fup, precision: 10, scale: 2
      t.decimal :royalties, precision: 10, scale: 2
      t.decimal :amount_receivable, precision: 10, scale: 2
      t.integer :payment_method
      t.string  :transaction_id, index: { unique: true }
      t.references :customer, null: false, foreign_key: true
      t.references :store, null: false, foreign_key: true
      t.timestamps
    end

    add_index :transactions, [ :customer_id, :store_id ]
  end
end
