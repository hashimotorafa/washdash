class AddCompanyIndexToUser < ActiveRecord::Migration[7.2]
  def change
    add_reference :users, :company, index: true
  end
end
