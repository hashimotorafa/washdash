class CreateTransactions < ActiveRecord::Migration[7.2]
  def change
    create_table :transactions do |t|
      t.string :amount
      t.string :payment_method_tax
      t.string :sub_acquirer
      t.string :amount_before_tax
      t.string :fup
      t.string :royalties
      t.string :amount_receivable
      t.integer :payment_method
      t.string :transaction_id
      t.references :customer, null: false, foreign_key: true
      t.references :store, null: false, foreign_key: true
      t.timestamps
    end
  end
end
