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

ActiveRecord::Schema[7.0].define(version: 2023_02_15_042944) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.boolean "expenses"
    t.boolean "deposits"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_accounts_on_user_id"
  end

  create_table "admin_access_logs", force: :cascade do |t|
    t.bigint "workspace_id"
    t.bigint "role_id"
    t.bigint "user_id"
    t.string "action"
    t.string "access_rule"
    t.string "details"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["role_id"], name: "index_admin_access_logs_on_role_id"
    t.index ["user_id"], name: "index_admin_access_logs_on_user_id"
    t.index ["workspace_id"], name: "index_admin_access_logs_on_workspace_id"
  end

  create_table "admin_crud_rules", force: :cascade do |t|
    t.bigint "role_id"
    t.bigint "workspace_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "c"
    t.boolean "r"
    t.boolean "u"
    t.boolean "d"
    t.boolean "s"
    t.boolean "p"
    t.index ["role_id"], name: "index_admin_crud_rules_on_role_id"
    t.index ["workspace_id"], name: "index_admin_crud_rules_on_workspace_id"
  end

  create_table "admin_custom_role_rules", force: :cascade do |t|
    t.bigint "custom_rule_id"
    t.bigint "role_id"
    t.boolean "access"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["custom_rule_id"], name: "index_admin_custom_role_rules_on_custom_rule_id"
    t.index ["role_id"], name: "index_admin_custom_role_rules_on_role_id"
  end

  create_table "admin_custom_rules", force: :cascade do |t|
    t.bigint "workspace_id"
    t.string "description"
    t.string "code"
    t.string "long_description"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["workspace_id"], name: "index_admin_custom_rules_on_workspace_id"
  end

  create_table "admin_roles", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email"
    t.string "name"
    t.boolean "active"
    t.text "options"
    t.bigint "role_id"
    t.string "remember_digest"
    t.string "password_digest"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "navbar"
    t.index ["email"], name: "index_admin_users_on_email"
    t.index ["role_id"], name: "index_admin_users_on_role_id"
  end

  create_table "admin_workspaces", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "bank_accounts", force: :cascade do |t|
    t.string "name"
    t.string "number"
    t.text "description"
    t.boolean "active"
    t.integer "account_type"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "dashboard"
    t.bigint "currency_id"
    t.bigint "user_id"
    t.index ["currency_id"], name: "index_bank_accounts_on_currency_id"
    t.index ["user_id"], name: "index_bank_accounts_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.integer "category_type"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_categories_on_user_id"
  end

  create_table "currencies", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.float "rate"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_currencies_on_user_id"
  end

  create_table "import_files", force: :cascade do |t|
    t.string "name"
    t.text "options"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reports", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "scheduler_items", force: :cascade do |t|
    t.float "amount"
    t.bigint "transaction_id"
    t.bigint "scheduler_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["scheduler_id"], name: "index_scheduler_items_on_scheduler_id"
    t.index ["transaction_id"], name: "index_scheduler_items_on_transaction_id"
  end

  create_table "scheduler_periods", force: :cascade do |t|
    t.string "name"
    t.integer "days"
    t.integer "months"
  end

  create_table "scheduler_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "schedulers", force: :cascade do |t|
    t.bigint "scheduler_type_id"
    t.bigint "bank_account_id"
    t.bigint "account_id"
    t.bigint "user_id"
    t.bigint "scheduler_period_id"
    t.bigint "sub_category_id"
    t.string "description"
    t.integer "split"
    t.float "amount"
    t.integer "transfer_bank_id"
    t.integer "transaction_type_id"
    t.datetime "last_payment", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "completed", default: false
    t.index ["account_id"], name: "index_schedulers_on_account_id"
    t.index ["bank_account_id"], name: "index_schedulers_on_bank_account_id"
    t.index ["scheduler_period_id"], name: "index_schedulers_on_scheduler_period_id"
    t.index ["scheduler_type_id"], name: "index_schedulers_on_scheduler_type_id"
    t.index ["sub_category_id"], name: "index_schedulers_on_sub_category_id"
    t.index ["user_id"], name: "index_schedulers_on_user_id"
  end

  create_table "sub_categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "category_id"
    t.index ["category_id"], name: "index_sub_categories_on_category_id"
  end

  create_table "transaction_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "transactions", force: :cascade do |t|
    t.float "amount", default: 0.0
    t.float "rated_amount", default: 0.0
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "description"
    t.boolean "transfer"
    t.bigint "bank_account_id"
    t.bigint "account_id"
    t.bigint "sub_category_id"
    t.bigint "transaction_type_id"
    t.index ["account_id"], name: "index_transactions_on_account_id"
    t.index ["bank_account_id"], name: "index_transactions_on_bank_account_id"
    t.index ["sub_category_id"], name: "index_transactions_on_sub_category_id"
    t.index ["transaction_type_id"], name: "index_transactions_on_transaction_type_id"
  end

  create_table "transfers", force: :cascade do |t|
    t.integer "from_id"
    t.integer "to_id"
    t.float "rate"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "description"
  end

end
