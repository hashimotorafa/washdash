class AddExternalIdIndexToCycles < ActiveRecord::Migration[7.2]
  def change
    add_index :cycles, :external_id, unique: true
  end
end
