# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160304204007) do

  create_table "headers", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.string   "value",      limit: 255, null: false
    t.integer  "mock_id",    limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "headers", ["mock_id"], name: "index_headers_on_mock_id", using: :btree

  create_table "mocks", force: :cascade do |t|
    t.string   "name",         limit: 255,   null: false
    t.text     "description",  limit: 65535
    t.integer  "status",       limit: 4,     null: false
    t.string   "content_type", limit: 255,   null: false
    t.string   "method",       limit: 255,   null: false
    t.string   "route_path",   limit: 255,   null: false
    t.string   "body_type",    limit: 255,   null: false
    t.text     "content",      limit: 65535, null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "mocks", ["name"], name: "index_mocks_on_name", unique: true, using: :btree
  add_index "mocks", ["route_path"], name: "index_mocks_on_route_path", unique: true, using: :btree

  add_foreign_key "headers", "mocks"
end