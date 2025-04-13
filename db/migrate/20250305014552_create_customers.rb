class CreateCustomers < ActiveRecord::Migration[7.2]
  def change
    create_table :customers do |t|
      t.string :name
      t.string :email,        null: false
      t.string :area_code,    null: false
      t.string :phone_number, null: false
      t.boolean :is_active,   default: true
      t.string :document_number
      t.timestamps
    end
  end
end
