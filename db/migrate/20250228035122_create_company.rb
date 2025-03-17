class CreateCompany < ActiveRecord::Migration[7.2]
  def change
    create_table :companies do |t|
      t.string :name
      t.string :city
      t.string :state
      t.integer :status, default: 0
      t.string :document_number
      t.timestamps
    end
  end
end
