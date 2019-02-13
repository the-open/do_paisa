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

ActiveRecord::Schema.define(version: 20190212192301) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pgcrypto"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "api_users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "key"
    t.string "allowed_origin"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "donor_emails", force: :cascade do |t|
    t.uuid "donor_id", null: false
    t.text "html", null: false
    t.text "subject", null: false
    t.text "sender_name", null: false
    t.text "sender_email", null: false
    t.text "status"
    t.text "external_id"
    t.datetime "opened_at"
    t.datetime "clicked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["donor_id"], name: "index_donor_emails_on_donor_id"
  end

  create_table "donors", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "processor_id"
    t.string "external_id"
    t.string "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "metadata"
    t.jsonb "data"
    t.text "source_system", null: false
    t.text "source_external_id", null: false
  end

  create_table "processor_email_templates", force: :cascade do |t|
    t.uuid "processor_id", null: false
    t.integer "email_type", null: false
    t.text "html", null: false
    t.text "subject", null: false
    t.text "sender_name", null: false
    t.text "sender_email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["processor_id"], name: "index_processor_email_templates_on_processor_id"
  end

  create_table "processors", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "type"
    t.string "name"
    t.string "api_key"
    t.string "api_secret"
    t.string "currency"
    t.jsonb "config"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "recurring_donors", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "donor_id"
    t.bigint "amount"
    t.date "last_charged_at"
    t.date "next_charge_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "processor_id"
    t.integer "consecutive_fail_count", default: 0, null: false
    t.datetime "ended_at"
    t.text "last_fail_reason"
    t.string "cancelled_reason"
  end

  create_table "settings", force: :cascade do |t|
    t.text "key", null: false
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_settings_on_key"
  end

  create_table "transactions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "processor_id"
    t.string "external_id"
    t.jsonb "data"
    t.bigint "amount"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "recurring_donor_id"
    t.boolean "recurring"
    t.uuid "donor_id"
    t.text "source_system", null: false
    t.text "source_external_id", null: false
  end

  create_table "webhooks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.uuid "processor_id"
    t.string "url"
    t.string "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "system"
    t.text "recurring_url"
  end

end
