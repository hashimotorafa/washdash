class CreateCustomerStores < ActiveRecord::Migration[7.2]
  def change
    create_table :customer_stores do |t|
      t.references :customer, null: false, foreign_key: true
      t.references :store, null: false, foreign_key: true
      t.datetime   :first_visit_date
      t.timestamps
    end
  end
end
