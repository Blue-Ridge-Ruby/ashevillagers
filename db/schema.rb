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

ActiveRecord::Schema[8.1].define(version: 2026_04_16_001409) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "configurations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.string "value"
    t.index ["name"], name: "index_configurations_on_name", unique: true
  end

  create_table "profile_answers", force: :cascade do |t|
    t.text "answer"
    t.datetime "created_at", null: false
    t.string "job_title"
    t.integer "profile_id", null: false
    t.integer "profile_question_id", null: false
    t.datetime "updated_at", null: false
    t.index ["profile_id", "profile_question_id"], name: "index_profile_answers_on_profile_id_and_profile_question_id", unique: true
    t.index ["profile_id"], name: "index_profile_answers_on_profile_id"
    t.index ["profile_question_id"], name: "index_profile_answers_on_profile_question_id"
  end

  create_table "profile_questions", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "llm_prompt"
    t.integer "position", default: 0, null: false
    t.text "question", null: false
    t.datetime "updated_at", null: false
  end

  create_table "profiles", force: :cascade do |t|
    t.string "bluesky_url"
    t.datetime "created_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "linkedin_url"
    t.string "mastodon_url"
    t.string "twitter_url"
    t.datetime "updated_at", null: false
    t.integer "villager_id", null: false
    t.string "website_url"
    t.index ["villager_id"], name: "index_profiles_on_villager_id", unique: true
  end

  create_table "stewards", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "mobile_phone"
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_stewards_on_email", unique: true
  end

  create_table "villagers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "tito_account_slug"
    t.string "tito_event_slug"
    t.string "tito_ticket_slug"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_villagers_on_email"
    t.index ["tito_ticket_slug"], name: "index_villagers_on_tito_ticket_slug", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "profile_answers", "profile_questions"
  add_foreign_key "profile_answers", "profiles"
  add_foreign_key "profiles", "villagers"
end
