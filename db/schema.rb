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

ActiveRecord::Schema[8.0].define(version: 2025_05_08_154218) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "user_type", default: "1"
    t.string "jti"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "student_id"
    t.string "full_name", default: "", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["jti"], name: "index_admin_users_on_jti"
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
    t.index ["student_id"], name: "index_admin_users_on_student_id"
    t.index ["user_type"], name: "index_admin_users_on_user_type"
  end

  create_table "audit_logs", force: :cascade do |t|
    t.string "record_type", null: false
    t.integer "record_id", null: false
    t.string "action", null: false
    t.jsonb "audited_changes", null: false
    t.bigint "admin_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_user_id"], name: "index_audit_logs_on_admin_user_id"
    t.index ["record_type", "record_id"], name: "index_audit_logs_on_record_type_and_record_id"
  end

  create_table "certificates", force: :cascade do |t|
    t.string "code", null: false
    t.string "title", null: false
    t.string "certificate_type", null: false
    t.date "issue_date", null: false
    t.date "expiry_date"
    t.boolean "is_verified", default: true
    t.string "metadata_id"
    t.bigint "student_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_certificates_on_code", unique: true
    t.index ["student_id"], name: "index_certificates_on_student_id"
  end

  create_table "face_verification_settings", force: :cascade do |t|
    t.bigint "admin_user_id", null: false
    t.integer "verification_timeout", default: 1800, null: false
    t.boolean "require_face_verification", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_user_id"], name: "index_face_verification_settings_on_admin_user_id"
  end

  create_table "students", force: :cascade do |t|
    t.string "code", null: false
    t.string "full_name", null: false
    t.string "id_card_number", null: false
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_students_on_code", unique: true
    t.index ["email"], name: "index_students_on_email", unique: true
    t.index ["id_card_number"], name: "index_students_on_id_card_number", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "admin_users", "students"
  add_foreign_key "audit_logs", "admin_users"
  add_foreign_key "certificates", "students"
  add_foreign_key "face_verification_settings", "admin_users"
end
