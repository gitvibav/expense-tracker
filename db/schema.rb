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

ActiveRecord::Schema[8.1].define(version: 2026_03_06_060429) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "expense_item_shares", force: :cascade do |t|
    t.integer "amount_cents"
    t.datetime "created_at", null: false
    t.integer "expense_item_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["expense_item_id"], name: "index_expense_item_shares_on_expense_item_id"
    t.index ["user_id"], name: "index_expense_item_shares_on_user_id"
  end

  create_table "expense_items", force: :cascade do |t|
    t.integer "amount_cents"
    t.datetime "created_at", null: false
    t.string "description"
    t.integer "expense_id", null: false
    t.datetime "updated_at", null: false
    t.index ["expense_id"], name: "index_expense_items_on_expense_id"
  end

  create_table "expense_splits", force: :cascade do |t|
    t.integer "amount_cents"
    t.datetime "created_at", null: false
    t.integer "expense_id", null: false
    t.integer "from_user_id", null: false
    t.integer "to_user_id", null: false
    t.datetime "updated_at", null: false
    t.index ["expense_id"], name: "index_expense_splits_on_expense_id"
    t.index ["from_user_id"], name: "index_expense_splits_on_from_user_id"
    t.index ["to_user_id"], name: "index_expense_splits_on_to_user_id"
  end

  create_table "expenses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description"
    t.integer "payer_id", null: false
    t.decimal "tax_percent"
    t.decimal "tip_percent"
    t.datetime "updated_at", null: false
    t.index ["payer_id"], name: "index_expenses_on_payer_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name"
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index "lower((email)::text)", name: "index_users_on_lower_email", unique: true
  end

  add_foreign_key "expense_item_shares", "expense_items"
  add_foreign_key "expense_item_shares", "users"
  add_foreign_key "expense_items", "expenses"
  add_foreign_key "expense_splits", "expenses"
  add_foreign_key "expense_splits", "users", column: "from_user_id"
  add_foreign_key "expense_splits", "users", column: "to_user_id"
  add_foreign_key "expenses", "users", column: "payer_id"
end
