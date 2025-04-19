# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2025_04_14_000000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "companies", force: :cascade do |t|
    t.string "name"
    t.string "city"
    t.string "state"
    t.integer "status", default: 0
    t.string "document_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "costs", force: :cascade do |t|
    t.string "name"
    t.bigint "income_statement_id", null: false
    t.bigint "store_id", null: false
    t.decimal "amount", precision: 10, scale: 2
    t.string "description"
    t.integer "category"
    t.integer "payment_method"
    t.integer "payment_status"
    t.date "payment_date"
    t.date "due_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["income_statement_id"], name: "index_costs_on_income_statement_id"
    t.index ["store_id"], name: "index_costs_on_store_id"
  end

  create_table "customers", force: :cascade do |t|
    t.string "name"
    t.string "email", null: false
    t.string "area_code", null: false
    t.string "phone_number", null: false
    t.boolean "is_active", default: true
    t.string "document_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cycles", force: :cascade do |t|
    t.bigint "external_id"
    t.string "status"
    t.string "price"
    t.string "machine_type"
    t.string "machine_number"
    t.string "description"
    t.bigint "customer_id", null: false
    t.bigint "store_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_cycles_on_customer_id"
    t.index ["external_id"], name: "index_cycles_on_external_id", unique: true
    t.index ["store_id"], name: "index_cycles_on_store_id"
  end

  create_table "external_accesses", force: :cascade do |t|
    t.string "email"
    t.string "password"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "company_id"
    t.index ["company_id"], name: "index_external_accesses_on_company_id"
  end

  create_table "income_statements", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.integer "year"
    t.integer "month"
    t.decimal "net_profit", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["store_id"], name: "index_income_statements_on_store_id"
  end

  create_table "machines", force: :cascade do |t|
    t.string "name"
    t.integer "machine_type"
    t.integer "number"
    t.bigint "store_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["store_id"], name: "index_machines_on_store_id"
  end

  create_table "stores", force: :cascade do |t|
    t.string "name"
    t.string "area_code"
    t.string "external_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "company_id"
    t.date "started_at"
    t.index ["company_id"], name: "index_stores_on_company_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.string "amount"
    t.string "payment_method_tax"
    t.string "sub_acquirer"
    t.string "amount_before_tax"
    t.string "fup"
    t.string "royalties"
    t.string "amount_receivable"
    t.integer "payment_method"
    t.string "transaction_id"
    t.bigint "customer_id", null: false
    t.bigint "store_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_transactions_on_customer_id"
    t.index ["store_id"], name: "index_transactions_on_store_id"
    t.index ["transaction_id"], name: "index_transactions_on_transaction_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.integer "status", default: 0, null: false
    t.integer "role", default: 0, null: false
    t.boolean "admin", default: false, null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "company_id"
    t.index ["company_id"], name: "index_users_on_company_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  add_foreign_key "costs", "income_statements"
  add_foreign_key "costs", "stores"
  add_foreign_key "cycles", "customers"
  add_foreign_key "cycles", "stores"
  add_foreign_key "income_statements", "stores"
  add_foreign_key "machines", "stores"
  add_foreign_key "transactions", "customers"
  add_foreign_key "transactions", "stores"
end
