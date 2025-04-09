class CreateCycles < ActiveRecord::Migration[7.2]
  def change
    create_table :cycles do |t|
      t.bigint :external_id
      t.string :status
      t.string :price
      t.string :machine_type
      t.string :machine_number
      t.string :description
      t.references :customer, null: false, foreign_key: true
      t.references :store, null: false, foreign_key: true
      t.timestamps
    end
  end
end
