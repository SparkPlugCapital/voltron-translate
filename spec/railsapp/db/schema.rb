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

ActiveRecord::Schema.define(version: 20170416210123) do

  create_table "companies", force: :cascade do |t|
    t.string "name"
    t.text "greeting"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "voltron_translations", force: :cascade do |t|
    t.integer "resource_id"
    t.string "resource_type"
    t.string "attribute_name"
    t.string "locale"
    t.text "translation"
    t.index ["attribute_name", "locale"], name: "index_voltron_translations_on_attribute_name_and_locale"
  end

end
