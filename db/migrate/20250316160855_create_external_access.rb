class CreateExternalAccess < ActiveRecord::Migration[7.0]
  def change
    create_table :external_accesses do |t|
      t.string :email
      t.string :password
      t.timestamps
    end

    add_reference :external_accesses, :company, index: true
  end
end
