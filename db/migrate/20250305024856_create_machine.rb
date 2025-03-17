class CreateMachine < ActiveRecord::Migration[7.2]
  def change
    create_table :machines do |t|
      t.string :name
      t.integer :machine_type
      t.integer :number
      t.references :store, null: false, foreign_key: true
      t.timestamps
    end
  end
end
