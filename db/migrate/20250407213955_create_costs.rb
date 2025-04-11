class CreateCosts < ActiveRecord::Migration[7.2]
  def change
    create_table :costs do |t|
      t.string :name
      t.references :income_statement, null: false, foreign_key: true
      t.references :store, null: false, foreign_key: true
      t.decimal :amount, precision: 10, scale: 2
      t.string :description
      t.integer :category
      t.integer :payment_method
      t.integer :payment_status
      t.date :payment_date
      t.date :due_date
      t.timestamps
    end
  end
end
