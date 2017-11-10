# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20171103211633) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "alias_archives", force: :cascade do |t|
    t.integer  "user_id",        null: false
    t.date     "effective_date", null: false
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "aliases", force: :cascade do |t|
    t.integer  "user_id",        null: false
    t.date     "effective_date", null: false
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "articles", force: :cascade do |t|
    t.integer  "alias_id",   null: false
    t.string   "title",      null: false
    t.text     "body",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "coordinate_archives", force: :cascade do |t|
    t.decimal  "latitude",   precision: 10, scale: 7
    t.decimal  "longitude",  precision: 10, scale: 7
    t.integer  "alias_id"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  create_table "coordinates", force: :cascade do |t|
    t.decimal  "latitude",   precision: 10, scale: 7
    t.decimal  "longitude",  precision: 10, scale: 7
    t.integer  "alias_id"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.index ["alias_id"], name: "index_coordinates_on_alias_id", unique: true, using: :btree
  end

  create_table "matched_alias_archives", force: :cascade do |t|
    t.integer  "alias_1_id",     null: false
    t.integer  "alias_2_id",     null: false
    t.date     "effective_date", null: false
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "matched_aliases", force: :cascade do |t|
    t.integer  "alias_id",         null: false
    t.integer  "matched_alias_id", null: false
    t.date     "effective_date",   null: false
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.index ["alias_id", "matched_alias_id", "effective_date"], name: "alias_matched_alias_date_index", unique: true, using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "name",                             null: false
    t.string   "email",                            null: false
    t.string   "token"
    t.string   "password_digest",                  null: false
    t.boolean  "opts_to_compute",  default: false
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.datetime "token_created_at"
    t.index ["opts_to_compute"], name: "index_users_on_opts_to_compute", using: :btree
    t.index ["token", "token_created_at"], name: "index_users_on_token_and_token_created_at", using: :btree
  end

  add_foreign_key "matched_aliases", "aliases", column: "matched_alias_id"
end
