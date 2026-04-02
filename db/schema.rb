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


ActiveRecord::Schema[8.1].define(version: 2026_03_31_013735) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "prescriptions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "dea_schedule"
    t.string "dosage"
    t.string "error_message"
    t.string "frequency"
    t.string "medication"
    t.string "patient_id"
    t.string "pharmacy_id"
    t.string "provider_id"
    t.integer "quantity"
    t.string "status"
    t.datetime "transmitted_at"
    t.datetime "updated_at", null: false
  end
  
  create_table "auth_tokens", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "doctor_id"
    t.datetime "expires_at"
    t.string "token"
    t.datetime "updated_at", null: false
  end

  create_table "doctors", force: :cascade do |t|
    t.boolean "active"
    t.datetime "created_at", null: false
    t.string "email"
    t.string "license_number"
    t.string "name"
    t.string "password_digest"
    t.datetime "updated_at", null: false
  end

  create_table "prescription_instructions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "doctor_id"
    t.string "dosage"
    t.string "duration"
    t.string "frequency"
    t.string "medication"
    t.text "notes"
    t.string "patient_id"
    t.string "pharmacy_id"
    t.integer "prescription_id", null: false
    t.string "provider_id"
    t.string "quantity"
    t.datetime "updated_at", null: false
    t.index ["doctor_id"], name: "index_prescription_instructions_on_doctor_id"
    t.index ["prescription_id"], name: "index_prescription_instructions_on_prescription_id"
  end

  create_table "transmission_logs", force: :cascade do |t|
    t.string "action"
    t.datetime "created_at", null: false
    t.integer "doctor_id"
    t.string "ip_address"
    t.integer "pharmacy_id"
    t.integer "prescription_id"
    t.string "status"
    t.datetime "updated_at", null: false
  end
end
