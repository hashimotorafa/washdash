class CreateStore < ActiveRecord::Migration[7.2]
  def change
    create_table "stores", force: :cascade do |t|
      t.string "name"
      t.string "area_code"
      t.string "external_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.bigint "company_id"
      t.date "started_at"
      t.index [ "company_id" ], name: "index_stores_on_company_id"
    end
  end
end
