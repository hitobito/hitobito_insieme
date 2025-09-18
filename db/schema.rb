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

ActiveRecord::Schema[7.1].define(version: 2025_05_27_090212) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "additional_addresses", force: :cascade do |t|
    t.string "contactable_type"
    t.bigint "contactable_id"
    t.string "name", null: false
    t.string "label", null: false
    t.string "street", null: false
    t.string "housenumber", limit: 20
    t.string "zip_code", null: false
    t.string "town", null: false
    t.string "country", null: false
    t.string "address_care_of"
    t.string "postbox"
    t.boolean "invoices", default: false, null: false
    t.boolean "uses_contactable_name", default: true, null: false
    t.boolean "public", default: false, null: false
    t.index ["contactable_id", "contactable_type", "label"], name: "idx_on_contactable_id_contactable_type_label_53043e4f10", unique: true
    t.index ["contactable_id", "contactable_type"], name: "index_additional_addresses_on_contactable_where_invoices_true", unique: true, where: "(invoices = true)"
    t.index ["contactable_type", "contactable_id"], name: "index_additional_addresses_on_contactable"
  end

  create_table "additional_emails", id: :serial, force: :cascade do |t|
    t.string "contactable_type", null: false
    t.integer "contactable_id", null: false
    t.string "email", null: false
    t.string "label"
    t.boolean "public", default: true, null: false
    t.boolean "mailings", default: true, null: false
    t.boolean "invoices", default: false
    t.virtual "search_column", type: :tsvector, as: "to_tsvector('simple'::regconfig, COALESCE((email)::text, ''::text))", stored: true
    t.index ["contactable_id", "contactable_type"], name: "index_additional_emails_on_contactable_id_and_contactable_type"
    t.index ["contactable_id", "contactable_type"], name: "index_additional_emails_on_contactable_where_invoices_true", unique: true, where: "(invoices = true)"
    t.index ["search_column"], name: "additional_emails_search_column_gin_idx", using: :gin
  end

  create_table "addresses", force: :cascade do |t|
    t.string "street_short", limit: 128, null: false
    t.string "street_short_old", limit: 128, null: false
    t.string "street_long", limit: 128, null: false
    t.string "street_long_old", limit: 128, null: false
    t.string "town", limit: 128, null: false
    t.integer "zip_code", null: false
    t.string "state", limit: 128, null: false
    t.text "numbers"
    t.virtual "search_column", type: :tsvector, as: "to_tsvector('simple'::regconfig, ((((((COALESCE((street_short)::text, ''::text) || ' '::text) || COALESCE((town)::text, ''::text)) || ' '::text) || COALESCE((zip_code)::text, ''::text)) || ' '::text) || COALESCE(numbers, ''::text)))", stored: true
    t.index ["search_column"], name: "addresses_search_column_gin_idx", using: :gin
    t.index ["zip_code", "street_short"], name: "index_addresses_on_zip_code_and_street_short"
  end

  create_table "assignments", force: :cascade do |t|
    t.bigint "person_id", null: false
    t.bigint "creator_id", null: false
    t.string "title", null: false
    t.text "description", null: false
    t.string "attachment_type"
    t.integer "attachment_id"
    t.date "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_assignments_on_creator_id"
    t.index ["person_id"], name: "index_assignments_on_person_id"
  end

  create_table "async_download_files", force: :cascade do |t|
    t.string "name", null: false
    t.string "filetype"
    t.integer "progress"
    t.integer "person_id", null: false
    t.string "timestamp", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "background_job_log_entries", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "job_name", null: false
    t.bigint "group_id"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.integer "attempt"
    t.string "status"
    t.json "payload"
    t.index ["group_id"], name: "index_background_job_log_entries_on_group_id"
    t.index ["job_id", "attempt"], name: "index_background_job_log_entries_on_job_id_and_attempt", unique: true
    t.index ["job_id"], name: "index_background_job_log_entries_on_job_id"
    t.index ["job_name"], name: "index_background_job_log_entries_on_job_name"
  end

  create_table "bounces", force: :cascade do |t|
    t.string "email", null: false
    t.integer "count", default: 0, null: false
    t.datetime "blocked_at"
    t.integer "mailing_list_ids", array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_bounces_on_email", unique: true
  end

  create_table "calendar_groups", force: :cascade do |t|
    t.bigint "calendar_id", null: false
    t.bigint "group_id", null: false
    t.boolean "excluded", default: false
    t.boolean "with_subgroups", default: false
    t.string "event_type"
    t.index ["calendar_id"], name: "index_calendar_groups_on_calendar_id"
    t.index ["group_id"], name: "index_calendar_groups_on_group_id"
  end

  create_table "calendar_tags", force: :cascade do |t|
    t.bigint "calendar_id", null: false
    t.integer "tag_id", null: false
    t.boolean "excluded", default: false
    t.index ["calendar_id"], name: "index_calendar_tags_on_calendar_id"
  end

  create_table "calendars", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "group_id", null: false
    t.text "description"
    t.string "token", null: false
    t.index ["group_id"], name: "index_calendars_on_group_id"
  end

  create_table "capital_substrates", id: :serial, force: :cascade do |t|
    t.integer "group_id", null: false
    t.integer "year", null: false
    t.decimal "organization_capital", precision: 12, scale: 2
    t.decimal "fund_building", precision: 12, scale: 2
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.decimal "earmarked_funds", precision: 12, scale: 2
    t.decimal "previous_substrate_sum", precision: 12, scale: 2
  end

  create_table "cors_origins", force: :cascade do |t|
    t.string "auth_method_type"
    t.bigint "auth_method_id"
    t.string "origin", null: false
    t.index ["auth_method_type", "auth_method_id"], name: "index_cors_origins_on_auth_method_type_and_auth_method_id"
    t.index ["origin"], name: "index_cors_origins_on_origin"
  end

  create_table "cost_accounting_records", id: :serial, force: :cascade do |t|
    t.integer "group_id", null: false
    t.integer "year", null: false
    t.string "report", null: false
    t.decimal "aufwand_ertrag_fibu", precision: 12, scale: 2
    t.decimal "abgrenzung_fibu", precision: 12, scale: 2
    t.decimal "abgrenzung_dachorganisation", precision: 12, scale: 2
    t.decimal "raeumlichkeiten", precision: 12, scale: 2
    t.decimal "verwaltung", precision: 12, scale: 2
    t.decimal "beratung", precision: 12, scale: 2
    t.decimal "treffpunkte", precision: 12, scale: 2
    t.decimal "blockkurse", precision: 12, scale: 2
    t.decimal "tageskurse", precision: 12, scale: 2
    t.decimal "jahreskurse", precision: 12, scale: 2
    t.decimal "lufeb", precision: 12, scale: 2
    t.decimal "mittelbeschaffung", precision: 12, scale: 2
    t.text "aufteilung_kontengruppen"
    t.decimal "medien_und_publikationen", precision: 12, scale: 2
    t.index ["group_id", "year", "report"], name: "index_cost_accounting_records_on_group_id_and_year_and_report", unique: true
  end

  create_table "custom_content_translations", force: :cascade do |t|
    t.integer "custom_content_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "label", null: false
    t.string "subject"
    t.index ["custom_content_id"], name: "index_custom_content_translations_on_custom_content_id"
    t.index ["locale"], name: "index_custom_content_translations_on_locale"
  end

  create_table "custom_contents", id: :serial, force: :cascade do |t|
    t.string "key", null: false
    t.string "placeholders_required"
    t.string "placeholders_optional"
    t.string "context_type"
    t.bigint "context_id"
    t.index ["context_type", "context_id"], name: "index_custom_contents_on_context"
  end

  create_table "delayed_jobs", id: :serial, force: :cascade do |t|
    t.integer "priority", default: 0
    t.integer "attempts", default: 0
    t.text "handler"
    t.text "last_error"
    t.datetime "run_at", precision: nil
    t.datetime "locked_at", precision: nil
    t.datetime "failed_at", precision: nil
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "delayed_workers", force: :cascade do |t|
    t.string "name"
    t.string "version"
    t.datetime "last_heartbeat_at", precision: nil
    t.string "host_name"
    t.string "label"
  end

  create_table "event_answers", id: :serial, force: :cascade do |t|
    t.integer "participation_id", null: false
    t.integer "question_id", null: false
    t.string "answer"
    t.index ["participation_id", "question_id"], name: "index_event_answers_on_participation_id_and_question_id", unique: true
  end

  create_table "event_applications", id: :serial, force: :cascade do |t|
    t.integer "priority_1_id", null: false
    t.integer "priority_2_id"
    t.integer "priority_3_id"
    t.boolean "approved", default: false, null: false
    t.boolean "rejected", default: false, null: false
    t.boolean "waiting_list", default: false, null: false
    t.text "waiting_list_comment"
  end

  create_table "event_attachments", id: :serial, force: :cascade do |t|
    t.integer "event_id", null: false
    t.string "visibility"
    t.index ["event_id"], name: "index_event_attachments_on_event_id"
  end

  create_table "event_course_records", id: :serial, force: :cascade do |t|
    t.integer "event_id", null: false
    t.string "inputkriterien", limit: 1
    t.boolean "subventioniert", default: true, null: false
    t.string "kursart"
    t.decimal "kursdauer", precision: 12, scale: 2
    t.integer "teilnehmende_behinderte"
    t.integer "teilnehmende_angehoerige"
    t.integer "teilnehmende_weitere"
    t.decimal "absenzen_behinderte", precision: 12, scale: 2
    t.decimal "absenzen_angehoerige", precision: 12, scale: 2
    t.decimal "absenzen_weitere", precision: 12, scale: 2
    t.integer "leiterinnen"
    t.integer "fachpersonen"
    t.integer "hilfspersonal_ohne_honorar"
    t.integer "hilfspersonal_mit_honorar"
    t.integer "kuechenpersonal"
    t.decimal "honorare_inkl_sozialversicherung", precision: 12, scale: 2
    t.decimal "unterkunft", precision: 12, scale: 2
    t.decimal "uebriges", precision: 12, scale: 2
    t.decimal "beitraege_teilnehmende", precision: 12, scale: 2
    t.boolean "spezielle_unterkunft", default: false, null: false
    t.integer "year"
    t.integer "teilnehmende_mehrfachbehinderte"
    t.decimal "direkter_aufwand", precision: 12, scale: 2
    t.decimal "gemeinkostenanteil", precision: 12, scale: 2
    t.datetime "gemeinkosten_updated_at", precision: nil
    t.string "zugeteilte_kategorie", limit: 2
    t.integer "challenged_canton_count_id"
    t.integer "affiliated_canton_count_id"
    t.integer "anzahl_kurse", default: 1
    t.decimal "tage_behinderte", precision: 12, scale: 2
    t.decimal "tage_angehoerige", precision: 12, scale: 2
    t.decimal "tage_weitere", precision: 12, scale: 2
    t.integer "betreuerinnen"
    t.decimal "betreuungsstunden", precision: 12, scale: 2
    t.index ["event_id"], name: "index_event_course_records_on_event_id", unique: true
  end

  create_table "event_dates", id: :serial, force: :cascade do |t|
    t.integer "event_id", null: false
    t.string "label"
    t.datetime "start_at", precision: nil
    t.datetime "finish_at", precision: nil
    t.string "location"
    t.index ["event_id", "start_at"], name: "index_event_dates_on_event_id_and_start_at"
    t.index ["event_id"], name: "index_event_dates_on_event_id"
  end

  create_table "event_general_cost_allocations", id: :serial, force: :cascade do |t|
    t.integer "group_id", null: false
    t.integer "year", null: false
    t.decimal "general_costs_blockkurse", precision: 12, scale: 2
    t.decimal "general_costs_tageskurse", precision: 12, scale: 2
    t.decimal "general_costs_semesterkurse", precision: 12, scale: 2
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.decimal "general_costs_treffpunkte", precision: 12, scale: 2
    t.index ["group_id", "year"], name: "index_event_general_cost_allocations_on_group_id_and_year", unique: true
  end

  create_table "event_invitations", force: :cascade do |t|
    t.string "participation_type", null: false
    t.datetime "declined_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "event_id", null: false
    t.bigint "person_id", null: false
    t.index ["event_id", "person_id"], name: "index_event_invitations_on_event_id_and_person_id", unique: true
    t.index ["event_id"], name: "index_event_invitations_on_event_id"
    t.index ["person_id"], name: "index_event_invitations_on_person_id"
  end

  create_table "event_kind_categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at", precision: nil
    t.integer "order"
  end

  create_table "event_kind_category_translations", force: :cascade do |t|
    t.bigint "event_kind_category_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "label"
    t.index ["event_kind_category_id"], name: "index_bef985968be46182fb95e23ef7afbbeaddf1dd11"
    t.index ["locale"], name: "index_event_kind_category_translations_on_locale"
  end

  create_table "event_kind_qualification_kinds", id: :serial, force: :cascade do |t|
    t.integer "event_kind_id", null: false
    t.integer "qualification_kind_id", null: false
    t.string "category", null: false
    t.string "role", null: false
    t.integer "grouping"
    t.string "validity", default: "valid_or_expired", null: false
    t.index ["category"], name: "index_event_kind_qualification_kinds_on_category"
    t.index ["role"], name: "index_event_kind_qualification_kinds_on_role"
  end

  create_table "event_kind_translations", force: :cascade do |t|
    t.integer "event_kind_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "label", null: false
    t.string "short_name"
    t.text "general_information"
    t.text "application_conditions"
    t.index ["event_kind_id"], name: "index_event_kind_translations_on_event_kind_id"
    t.index ["locale"], name: "index_event_kind_translations_on_locale"
  end

  create_table "event_kinds", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.datetime "deleted_at", precision: nil
    t.integer "minimum_age"
    t.integer "kind_category_id"
  end

  create_table "event_participation_canton_counts", id: :serial, force: :cascade do |t|
    t.integer "ag"
    t.integer "ai"
    t.integer "ar"
    t.integer "be"
    t.integer "bl"
    t.integer "bs"
    t.integer "fr"
    t.integer "ge"
    t.integer "gl"
    t.integer "gr"
    t.integer "ju"
    t.integer "lu"
    t.integer "ne"
    t.integer "nw"
    t.integer "ow"
    t.integer "sg"
    t.integer "sh"
    t.integer "so"
    t.integer "sz"
    t.integer "tg"
    t.integer "ti"
    t.integer "ur"
    t.integer "vd"
    t.integer "vs"
    t.integer "zg"
    t.integer "zh"
    t.integer "another"
  end

  create_table "event_participations", id: :serial, force: :cascade do |t|
    t.integer "event_id", null: false
    t.integer "person_id", null: false
    t.text "additional_information"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.boolean "active", default: false, null: false
    t.integer "application_id"
    t.boolean "qualified"
    t.text "invoice_text"
    t.decimal "invoice_amount", precision: 12, scale: 2
    t.string "disability"
    t.boolean "multiple_disability"
    t.boolean "wheel_chair", default: false, null: false
    t.index ["application_id"], name: "index_event_participations_on_application_id"
    t.index ["event_id", "person_id"], name: "index_event_participations_on_event_id_and_person_id", unique: true
    t.index ["event_id"], name: "index_event_participations_on_event_id"
    t.index ["person_id"], name: "index_event_participations_on_person_id"
  end

  create_table "event_question_translations", force: :cascade do |t|
    t.integer "event_question_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "question"
    t.string "choices"
    t.index ["event_question_id"], name: "index_event_question_translations_on_event_question_id"
    t.index ["locale"], name: "index_event_question_translations_on_locale"
  end

  create_table "event_questions", id: :serial, force: :cascade do |t|
    t.integer "event_id"
    t.boolean "multiple_choices", default: false, null: false
    t.boolean "admin", default: false, null: false
    t.string "disclosure"
    t.string "type", null: false
    t.integer "derived_from_question_id"
    t.string "event_type"
    t.index ["derived_from_question_id"], name: "index_event_questions_on_derived_from_question_id"
    t.index ["event_id"], name: "index_event_questions_on_event_id"
  end

  create_table "event_role_type_orders", force: :cascade do |t|
    t.string "name"
    t.integer "order_weight"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "event_roles", id: :serial, force: :cascade do |t|
    t.string "type", null: false
    t.integer "participation_id", null: false
    t.string "label"
    t.index ["participation_id"], name: "index_event_roles_on_participation_id"
    t.index ["type"], name: "index_event_roles_on_type"
  end

  create_table "event_translations", force: :cascade do |t|
    t.integer "event_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.text "description"
    t.text "application_conditions"
    t.string "signature_confirmation_text"
    t.virtual "search_column", type: :tsvector, as: "to_tsvector('simple'::regconfig, COALESCE((name)::text, ''::text))", stored: true
    t.index ["event_id"], name: "index_event_translations_on_event_id"
    t.index ["locale"], name: "index_event_translations_on_locale"
    t.index ["search_column"], name: "event_translations_search_column_gin_idx", using: :gin
  end

  create_table "events", id: :serial, force: :cascade do |t|
    t.string "type"
    t.string "number"
    t.string "motto"
    t.string "cost"
    t.integer "maximum_participants"
    t.integer "contact_id"
    t.text "location"
    t.date "application_opening_at"
    t.date "application_closing_at"
    t.integer "kind_id"
    t.string "state", limit: 60
    t.boolean "priorization", default: false, null: false
    t.boolean "requires_approval", default: false, null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "participant_count", default: 0
    t.integer "application_contact_id"
    t.boolean "external_applications", default: false
    t.integer "applicant_count", default: 0
    t.integer "teamer_count", default: 0
    t.boolean "signature"
    t.boolean "signature_confirmation"
    t.integer "creator_id"
    t.integer "updater_id"
    t.boolean "applications_cancelable", default: false, null: false
    t.text "required_contact_attrs"
    t.text "hidden_contact_attrs"
    t.boolean "display_booking_info", default: true, null: false
    t.boolean "participations_visible", default: false, null: false
    t.boolean "waiting_list", default: true, null: false
    t.boolean "globally_visible"
    t.string "shared_access_token"
    t.boolean "notify_contact_on_participations", default: false, null: false
    t.decimal "training_days", precision: 5, scale: 2
    t.integer "minimum_participants"
    t.boolean "automatic_assignment", default: false, null: false
    t.string "visible_contact_attributes", default: "[\"name\", \"address\", \"phone_number\", \"email\", \"social_account\"]"
    t.string "leistungskategorie"
    t.string "fachkonzept"
    t.virtual "search_column", type: :tsvector, as: "to_tsvector('simple'::regconfig, COALESCE((number)::text, ''::text))", stored: true
    t.index ["kind_id"], name: "index_events_on_kind_id"
    t.index ["search_column"], name: "events_search_column_gin_idx", using: :gin
    t.index ["shared_access_token"], name: "index_events_on_shared_access_token"
  end

  create_table "events_groups", id: false, force: :cascade do |t|
    t.integer "event_id"
    t.integer "group_id"
    t.index ["event_id", "group_id"], name: "index_events_groups_on_event_id_and_group_id", unique: true
  end

  create_table "family_members", force: :cascade do |t|
    t.bigint "person_id", null: false
    t.string "kind", null: false
    t.bigint "other_id", null: false
    t.string "family_key", null: false
    t.index ["family_key"], name: "index_family_members_on_family_key"
    t.index ["other_id"], name: "index_family_members_on_other_id"
    t.index ["person_id", "other_id"], name: "index_family_members_on_person_id_and_other_id", unique: true
    t.index ["person_id"], name: "index_family_members_on_person_id"
  end

  create_table "global_values", id: :serial, force: :cascade do |t|
    t.integer "default_reporting_year", null: false
    t.integer "reporting_frozen_until_year"
  end

  create_table "group_translations", force: :cascade do |t|
    t.bigint "group_id", null: false
    t.string "locale", null: false
    t.string "privacy_policy_title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "custom_self_registration_title"
    t.index ["group_id", "locale"], name: "index_group_translations_on_group_id_and_locale", unique: true
    t.index ["group_id"], name: "index_group_translations_on_group_id"
  end

  create_table "group_type_orders", force: :cascade do |t|
    t.string "name"
    t.integer "order_weight"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "groups", id: :serial, force: :cascade do |t|
    t.integer "parent_id"
    t.integer "lft"
    t.integer "rgt"
    t.string "name"
    t.string "short_name", limit: 31
    t.string "type", null: false
    t.string "email"
    t.integer "zip_code"
    t.string "town"
    t.string "country"
    t.integer "contact_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.datetime "deleted_at", precision: nil
    t.integer "layer_group_id"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "deleter_id"
    t.boolean "require_person_add_requests", default: false, null: false
    t.text "description"
    t.datetime "archived_at", precision: nil
    t.string "self_registration_role_type"
    t.string "self_registration_notification_email"
    t.string "privacy_policy"
    t.string "nextcloud_url"
    t.boolean "main_self_registration_group", default: false, null: false
    t.string "encrypted_text_message_username"
    t.string "encrypted_text_message_password"
    t.string "text_message_provider", default: "aspsms", null: false
    t.string "text_message_originator"
    t.string "letter_address_position", default: "left", null: false
    t.boolean "self_registration_require_adult_consent", default: false, null: false
    t.string "street"
    t.string "housenumber", limit: 20
    t.string "address_care_of"
    t.string "postbox"
    t.string "full_name"
    t.integer "vid"
    t.integer "bsv_number"
    t.string "canton"
    t.virtual "search_column", type: :tsvector, as: "to_tsvector('simple'::regconfig, ((((((((((((((COALESCE((name)::text, ''::text) || ' '::text) || COALESCE((short_name)::text, ''::text)) || ' '::text) || COALESCE((email)::text, ''::text)) || ' '::text) || COALESCE((street)::text, ''::text)) || ' '::text) || COALESCE((housenumber)::text, ''::text)) || ' '::text) || COALESCE((zip_code)::text, ''::text)) || ' '::text) || COALESCE((town)::text, ''::text)) || ' '::text) || COALESCE((country)::text, ''::text)))", stored: true
    t.index ["layer_group_id"], name: "index_groups_on_layer_group_id"
    t.index ["lft", "rgt"], name: "index_groups_on_lft_and_rgt"
    t.index ["parent_id"], name: "index_groups_on_parent_id"
    t.index ["search_column"], name: "groups_search_column_gin_idx", using: :gin
    t.index ["type"], name: "index_groups_on_type"
  end

  create_table "help_text_translations", force: :cascade do |t|
    t.integer "help_text_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["help_text_id"], name: "index_help_text_translations_on_help_text_id"
    t.index ["locale"], name: "index_help_text_translations_on_locale"
  end

  create_table "help_texts", id: :serial, force: :cascade do |t|
    t.string "controller", limit: 100, null: false
    t.string "model", limit: 100
    t.string "kind", limit: 100, null: false
    t.string "name", limit: 100, null: false
    t.index ["controller", "model", "kind", "name"], name: "index_help_texts_fields", unique: true
  end

  create_table "hitobito_log_entries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "category", null: false
    t.integer "level", null: false
    t.text "message", null: false
    t.string "subject_type"
    t.bigint "subject_id"
    t.json "payload"
    t.index ["category", "level", "subject_id", "subject_type", "message"], name: "index_hitobito_log_entries_on_multiple_columns"
    t.index ["level"], name: "index_hitobito_log_entries_on_level"
    t.index ["subject_type", "subject_id"], name: "index_hitobito_log_entries_on_subject"
  end

  create_table "invoice_articles", id: :serial, force: :cascade do |t|
    t.string "number"
    t.string "name", null: false
    t.text "description"
    t.string "category"
    t.decimal "unit_cost", precision: 12, scale: 2
    t.decimal "vat_rate", precision: 5, scale: 2
    t.string "cost_center"
    t.string "account"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "group_id", null: false
    t.index ["number", "group_id"], name: "index_invoice_articles_on_number_and_group_id", unique: true
  end

  create_table "invoice_configs", id: :serial, force: :cascade do |t|
    t.integer "sequence_number", default: 1, null: false
    t.integer "due_days", default: 30, null: false
    t.integer "group_id", null: false
    t.text "address"
    t.text "payment_information"
    t.string "account_number"
    t.string "iban"
    t.string "payment_slip", default: "qr", null: false
    t.text "beneficiary"
    t.text "payee"
    t.string "participant_number"
    t.string "email"
    t.string "vat_number"
    t.string "currency", default: "CHF", null: false
    t.integer "donation_calculation_year_amount"
    t.integer "donation_increase_percentage"
    t.string "sender_name"
    t.string "logo_position", default: "disabled", null: false
    t.integer "reference_prefix"
    t.index ["group_id"], name: "index_invoice_configs_on_group_id"
  end

  create_table "invoice_items", id: :serial, force: :cascade do |t|
    t.integer "invoice_id", null: false
    t.string "name", null: false
    t.text "description"
    t.decimal "vat_rate", precision: 5, scale: 2
    t.decimal "unit_cost", precision: 12, scale: 2, null: false
    t.integer "count", default: 1, null: false
    t.string "cost_center"
    t.string "account"
    t.string "type", default: "InvoiceItem", null: false
    t.decimal "cost", precision: 12, scale: 2
    t.text "dynamic_cost_parameters"
    t.virtual "search_column", type: :tsvector, as: "to_tsvector('simple'::regconfig, ((((COALESCE((name)::text, ''::text) || ' '::text) || COALESCE((account)::text, ''::text)) || ' '::text) || COALESCE((cost_center)::text, ''::text)))", stored: true
    t.index ["invoice_id"], name: "index_invoice_items_on_invoice_id"
    t.index ["search_column"], name: "invoice_items_search_column_gin_idx", using: :gin
  end

  create_table "invoice_lists", force: :cascade do |t|
    t.string "receiver_type"
    t.bigint "receiver_id"
    t.bigint "group_id"
    t.bigint "creator_id"
    t.string "title", null: false
    t.decimal "amount_total", precision: 15, scale: 2, default: "0.0", null: false
    t.decimal "amount_paid", precision: 15, scale: 2, default: "0.0", null: false
    t.integer "recipients_total", default: 0, null: false
    t.integer "recipients_paid", default: 0, null: false
    t.integer "recipients_processed", default: 0, null: false
    t.text "invalid_recipient_ids"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "receivers"
    t.index ["creator_id"], name: "index_invoice_lists_on_creator_id"
    t.index ["group_id"], name: "index_invoice_lists_on_group_id"
    t.index ["receiver_type", "receiver_id"], name: "index_invoice_lists_on_receiver_type_and_receiver_id"
  end

  create_table "invoices", id: :serial, force: :cascade do |t|
    t.string "title", null: false
    t.string "sequence_number", null: false
    t.string "state", default: "draft", null: false
    t.string "esr_number", null: false
    t.text "description"
    t.string "recipient_email"
    t.text "recipient_address"
    t.date "sent_at"
    t.date "due_at"
    t.integer "group_id", null: false
    t.integer "recipient_id"
    t.decimal "total", precision: 12, scale: 2
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "account_number"
    t.text "address"
    t.date "issued_at"
    t.string "iban"
    t.text "payment_purpose"
    t.text "payment_information"
    t.string "payment_slip", default: "ch_es", null: false
    t.text "beneficiary"
    t.text "payee"
    t.string "participant_number"
    t.integer "creator_id"
    t.string "vat_number"
    t.string "currency", default: "CHF", null: false
    t.bigint "invoice_list_id"
    t.string "reference", null: false
    t.boolean "hide_total", default: false, null: false
    t.virtual "search_column", type: :tsvector, as: "to_tsvector('simple'::regconfig, ((((COALESCE((title)::text, ''::text) || ' '::text) || COALESCE((reference)::text, ''::text)) || ' '::text) || COALESCE((sequence_number)::text, ''::text)))", stored: true
    t.index ["esr_number"], name: "index_invoices_on_esr_number"
    t.index ["group_id"], name: "index_invoices_on_group_id"
    t.index ["invoice_list_id"], name: "index_invoices_on_invoice_list_id"
    t.index ["recipient_id"], name: "index_invoices_on_recipient_id"
    t.index ["search_column"], name: "invoices_search_column_gin_idx", using: :gin
    t.index ["sequence_number"], name: "index_invoices_on_sequence_number"
  end

  create_table "label_format_translations", force: :cascade do |t|
    t.integer "label_format_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", null: false
    t.index ["label_format_id"], name: "index_label_format_translations_on_label_format_id"
    t.index ["locale"], name: "index_label_format_translations_on_locale"
  end

  create_table "label_formats", id: :serial, force: :cascade do |t|
    t.string "page_size", default: "A4", null: false
    t.boolean "landscape", default: false, null: false
    t.float "font_size", default: 11.0, null: false
    t.float "width", null: false
    t.float "height", null: false
    t.integer "count_horizontal", null: false
    t.integer "count_vertical", null: false
    t.float "padding_top", null: false
    t.float "padding_left", null: false
    t.integer "person_id"
    t.boolean "nickname", default: false, null: false
    t.string "pp_post", limit: 23
  end

  create_table "locations", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "canton", limit: 2, null: false
    t.string "zip_code", null: false
    t.index ["zip_code", "canton", "name"], name: "index_locations_on_zip_code_and_canton_and_name", unique: true
  end

  create_table "mail_logs", id: :serial, force: :cascade do |t|
    t.string "mail_from"
    t.string "mail_hash"
    t.integer "status", default: 0
    t.string "mailing_list_name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "message_id"
    t.index ["mail_hash"], name: "index_mail_logs_on_mail_hash"
    t.index ["message_id"], name: "index_mail_logs_on_message_id"
  end

  create_table "mailing_lists", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.integer "group_id", null: false
    t.text "description"
    t.string "publisher"
    t.string "mail_name"
    t.string "additional_sender"
    t.boolean "subscribers_may_post", default: false, null: false
    t.boolean "anyone_may_post", default: false, null: false
    t.string "preferred_labels"
    t.boolean "delivery_report", default: false, null: false
    t.boolean "main_email", default: false
    t.string "mailchimp_api_key"
    t.string "mailchimp_list_id"
    t.boolean "mailchimp_syncing", default: false
    t.datetime "mailchimp_last_synced_at", precision: nil
    t.text "mailchimp_result"
    t.boolean "mailchimp_include_additional_emails", default: false
    t.text "filter_chain"
    t.string "subscribable_for", default: "nobody", null: false
    t.string "subscribable_mode"
    t.text "mailchimp_forgotten_emails"
    t.index ["group_id"], name: "index_mailing_lists_on_group_id"
  end

  create_table "message_recipients", force: :cascade do |t|
    t.bigint "message_id", null: false
    t.bigint "person_id"
    t.string "phone_number"
    t.string "email"
    t.text "address"
    t.datetime "created_at", precision: nil
    t.datetime "failed_at", precision: nil
    t.text "error"
    t.bigint "invoice_id"
    t.string "state"
    t.string "salutation", default: ""
    t.index ["invoice_id"], name: "index_message_recipients_on_invoice_id"
    t.index ["message_id"], name: "index_message_recipients_on_message_id"
    t.index ["person_id", "message_id", "address"], name: "index_message_recipients_on_person_message_address", unique: true
    t.index ["person_id", "message_id", "email"], name: "index_message_recipients_on_person_message_email", unique: true
    t.index ["person_id", "message_id", "phone_number"], name: "index_message_recipients_on_person_message_phone_number", unique: true
    t.index ["person_id"], name: "index_message_recipients_on_person_id"
  end

  create_table "message_templates", force: :cascade do |t|
    t.string "templated_type"
    t.bigint "templated_id"
    t.string "title", null: false
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["templated_type", "templated_id"], name: "index_message_templates_on_templated"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "mailing_list_id"
    t.bigint "sender_id"
    t.string "type", null: false
    t.string "subject", limit: 998
    t.string "state", default: "draft"
    t.integer "recipient_count", default: 0
    t.integer "success_count", default: 0
    t.integer "failed_count", default: 0
    t.datetime "sent_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "invoice_attributes"
    t.bigint "invoice_list_id"
    t.text "text"
    t.string "salutation"
    t.string "pp_post"
    t.string "shipping_method", default: "own"
    t.boolean "send_to_households", default: false, null: false
    t.boolean "donation_confirmation", default: false, null: false
    t.text "raw_source"
    t.string "date_location_text"
    t.string "uid"
    t.integer "bounce_parent_id"
    t.integer "blocked_count", default: 0
    t.index ["invoice_list_id"], name: "index_messages_on_invoice_list_id"
    t.index ["mailing_list_id"], name: "index_messages_on_mailing_list_id"
    t.index ["sender_id"], name: "index_messages_on_sender_id"
  end

  create_table "mounted_attributes", force: :cascade do |t|
    t.string "key", null: false
    t.integer "entry_id", null: false
    t.string "entry_type", null: false
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "notes", id: :serial, force: :cascade do |t|
    t.integer "subject_id", null: false
    t.integer "author_id", null: false
    t.text "text"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "subject_type"
    t.index ["subject_id"], name: "index_notes_on_subject_id"
  end

  create_table "oauth_access_grants", id: :serial, force: :cascade do |t|
    t.integer "resource_owner_id", null: false
    t.integer "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "revoked_at", precision: nil
    t.string "scopes"
    t.string "code_challenge"
    t.string "code_challenge_method"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", id: :serial, force: :cascade do |t|
    t.integer "resource_owner_id"
    t.integer "application_id"
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.datetime "revoked_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.string "scopes"
    t.string "previous_refresh_token", default: "", null: false
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.boolean "confidential", default: true, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "skip_consent_screen", default: false
    t.string "additional_audiences"
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "oauth_openid_requests", id: :serial, force: :cascade do |t|
    t.integer "access_grant_id", null: false
    t.string "nonce", null: false
  end

  create_table "payees", force: :cascade do |t|
    t.bigint "person_id"
    t.bigint "payment_id", null: false
    t.string "person_name"
    t.text "person_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["payment_id"], name: "index_payees_on_payment_id"
    t.index ["person_id"], name: "index_payees_on_person_id"
  end

  create_table "payment_provider_configs", force: :cascade do |t|
    t.string "payment_provider"
    t.bigint "invoice_config_id"
    t.integer "status", default: 0, null: false
    t.string "partner_identifier"
    t.string "user_identifier"
    t.string "encrypted_password"
    t.text "encrypted_keys"
    t.datetime "synced_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invoice_config_id"], name: "index_payment_provider_configs_on_invoice_config_id"
  end

  create_table "payment_reminder_config_translations", force: :cascade do |t|
    t.integer "payment_reminder_config_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.string "text"
    t.index ["locale"], name: "index_payment_reminder_config_translations_on_locale"
    t.index ["payment_reminder_config_id"], name: "index_1502ce89689ed6b058f113a54ae6292c8ecef22d"
  end

  create_table "payment_reminder_configs", id: :serial, force: :cascade do |t|
    t.integer "invoice_config_id", null: false
    t.integer "due_days", null: false
    t.integer "level", null: false
    t.boolean "show_invoice_description", default: true, null: false
    t.index ["invoice_config_id"], name: "index_payment_reminder_configs_on_invoice_config_id"
  end

  create_table "payment_reminders", id: :serial, force: :cascade do |t|
    t.integer "invoice_id", null: false
    t.date "due_at", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "title"
    t.string "text"
    t.integer "level"
    t.boolean "show_invoice_description", default: true, null: false
    t.index ["invoice_id"], name: "index_payment_reminders_on_invoice_id"
  end

  create_table "payments", id: :serial, force: :cascade do |t|
    t.integer "invoice_id"
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.date "received_at", null: false
    t.string "reference"
    t.string "transaction_identifier"
    t.string "status"
    t.text "transaction_xml"
    t.index ["invoice_id"], name: "index_payments_on_invoice_id"
    t.index ["transaction_identifier"], name: "index_payments_on_transaction_identifier", unique: true
  end

  create_table "people", id: :serial, force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "company_name"
    t.string "nickname"
    t.boolean "company", default: false, null: false
    t.string "email"
    t.string "zip_code"
    t.string "town"
    t.string "country"
    t.string "gender", limit: 1
    t.date "birthday"
    t.text "additional_information"
    t.boolean "contact_data_visible", default: false, null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "encrypted_password"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.integer "last_label_format_id"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "primary_group_id"
    t.integer "failed_attempts", default: 0
    t.datetime "locked_at", precision: nil
    t.string "authentication_token"
    t.boolean "show_global_label_formats", default: true, null: false
    t.string "household_key"
    t.string "event_feed_token"
    t.string "unlock_token"
    t.string "family_key"
    t.string "confirmation_token"
    t.datetime "confirmed_at", precision: nil
    t.datetime "confirmation_sent_at", precision: nil
    t.string "unconfirmed_email"
    t.string "reset_password_sent_to"
    t.integer "two_factor_authentication"
    t.text "encrypted_two_fa_secret"
    t.string "language", default: "de", null: false
    t.datetime "privacy_policy_accepted_at", precision: nil
    t.datetime "minimized_at", precision: nil
    t.bigint "self_registration_reason_id"
    t.string "self_registration_reason_custom_text", limit: 100
    t.datetime "inactivity_block_warning_sent_at", precision: nil
    t.datetime "blocked_at", precision: nil
    t.string "membership_verify_token"
    t.string "street"
    t.string "housenumber", limit: 20
    t.string "address_care_of"
    t.string "postbox"
    t.string "salutation"
    t.string "canton"
    t.string "correspondence_language"
    t.string "correspondence_general_company_name"
    t.boolean "correspondence_general_company", default: false, null: false
    t.text "correspondence_general_address"
    t.integer "correspondence_general_zip_code"
    t.string "correspondence_general_town"
    t.string "correspondence_general_country"
    t.string "billing_general_company_name"
    t.boolean "billing_general_company", default: false, null: false
    t.text "billing_general_address"
    t.integer "billing_general_zip_code"
    t.string "billing_general_town"
    t.string "billing_general_country"
    t.string "correspondence_course_company_name"
    t.boolean "correspondence_course_company", default: false, null: false
    t.text "correspondence_course_address"
    t.integer "correspondence_course_zip_code"
    t.string "correspondence_course_town"
    t.string "correspondence_course_country"
    t.string "billing_course_company_name"
    t.boolean "billing_course_company", default: false, null: false
    t.text "billing_course_address"
    t.integer "billing_course_zip_code"
    t.string "billing_course_town"
    t.string "billing_course_country"
    t.integer "number"
    t.boolean "correspondence_general_same_as_main", default: true
    t.boolean "billing_general_same_as_main", default: true
    t.boolean "correspondence_course_same_as_main", default: true
    t.boolean "billing_course_same_as_main", default: true
    t.string "correspondence_general_salutation"
    t.string "correspondence_general_first_name"
    t.string "correspondence_general_last_name"
    t.string "billing_general_salutation"
    t.string "billing_general_first_name"
    t.string "billing_general_last_name"
    t.string "correspondence_course_salutation"
    t.string "correspondence_course_first_name"
    t.string "correspondence_course_last_name"
    t.string "billing_course_salutation"
    t.string "billing_course_first_name"
    t.string "billing_course_last_name"
    t.string "dossier"
    t.string "ahv_number"
    t.integer "reference_person_number"
    t.boolean "disabled_person_reference", default: false
    t.string "disabled_person_first_name"
    t.string "disabled_person_last_name"
    t.string "disabled_person_address", limit: 1024
    t.integer "disabled_person_zip_code"
    t.string "disabled_person_town"
    t.date "disabled_person_birthday"
    t.string "correspondence_general_label", limit: 20
    t.string "billing_general_label", limit: 20
    t.string "correspondence_course_label", limit: 20
    t.string "billing_course_label", limit: 20
    t.virtual "search_column", type: :tsvector, as: "to_tsvector('simple'::regconfig, ((((((((((((((((((((((((((((COALESCE((first_name)::text, ''::text) || ' '::text) || COALESCE((last_name)::text, ''::text)) || ' '::text) || COALESCE((company_name)::text, ''::text)) || ' '::text) || COALESCE((nickname)::text, ''::text)) || ' '::text) || COALESCE((email)::text, ''::text)) || ' '::text) || COALESCE((street)::text, ''::text)) || ' '::text) || COALESCE((housenumber)::text, ''::text)) || ' '::text) || COALESCE((zip_code)::text, ''::text)) || ' '::text) || COALESCE((town)::text, ''::text)) || ' '::text) || COALESCE((country)::text, ''::text)) || ' '::text) ||\nCASE\n    WHEN (birthday IS NOT NULL) THEN (((((EXTRACT(year FROM birthday))::text || '-'::text) || lpad((EXTRACT(month FROM birthday))::text, 2, '0'::text)) || '-'::text) || lpad((EXTRACT(day FROM birthday))::text, 2, '0'::text))\n    ELSE ''::text\nEND) || ' '::text) || COALESCE(additional_information, ''::text)) || ' '::text) || COALESCE((number)::text, ''::text)) || ' '::text) || COALESCE((salutation)::text, ''::text)) || ' '::text) || COALESCE((canton)::text, ''::text)))", stored: true
    t.index ["authentication_token"], name: "index_people_on_authentication_token"
    t.index ["confirmation_token"], name: "index_people_on_confirmation_token", unique: true
    t.index ["email"], name: "index_people_on_email", unique: true
    t.index ["event_feed_token"], name: "index_people_on_event_feed_token", unique: true
    t.index ["first_name"], name: "index_people_on_first_name"
    t.index ["household_key"], name: "index_people_on_household_key"
    t.index ["last_name"], name: "index_people_on_last_name"
    t.index ["number"], name: "index_people_on_number", unique: true
    t.index ["reset_password_token"], name: "index_people_on_reset_password_token", unique: true
    t.index ["search_column"], name: "people_search_column_gin_idx", using: :gin
    t.index ["self_registration_reason_id"], name: "index_people_on_self_registration_reason_id"
    t.index ["unlock_token"], name: "index_people_on_unlock_token", unique: true
  end

  create_table "people_filters", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.integer "group_id"
    t.string "group_type"
    t.text "filter_chain"
    t.string "range", default: "deep"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["group_id", "group_type"], name: "index_people_filters_on_group_id_and_group_type"
  end

  create_table "person_add_request_ignored_approvers", id: :serial, force: :cascade do |t|
    t.integer "group_id", null: false
    t.integer "person_id", null: false
    t.index ["group_id", "person_id"], name: "person_add_request_ignored_approvers_index", unique: true
  end

  create_table "person_add_requests", id: :serial, force: :cascade do |t|
    t.integer "person_id", null: false
    t.integer "requester_id", null: false
    t.string "type", null: false
    t.integer "body_id", null: false
    t.string "role_type"
    t.datetime "created_at", precision: nil, null: false
    t.index ["person_id"], name: "index_person_add_requests_on_person_id"
    t.index ["type", "body_id"], name: "index_person_add_requests_on_type_and_body_id"
  end

  create_table "person_duplicates", force: :cascade do |t|
    t.integer "person_1_id", null: false
    t.integer "person_2_id", null: false
    t.boolean "ignore", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["person_1_id", "person_2_id"], name: "index_person_duplicates_on_person_1_id_and_person_2_id", unique: true
  end

  create_table "phone_numbers", id: :serial, force: :cascade do |t|
    t.string "contactable_type", null: false
    t.integer "contactable_id", null: false
    t.string "number", null: false
    t.string "label"
    t.boolean "public", default: true, null: false
    t.virtual "search_column", type: :tsvector, as: "to_tsvector('simple'::regconfig, COALESCE((number)::text, ''::text))", stored: true
    t.index ["contactable_id", "contactable_type"], name: "index_phone_numbers_on_contactable_id_and_contactable_type"
    t.index ["search_column"], name: "phone_numbers_search_column_gin_idx", using: :gin
  end

  create_table "qualification_kind_translations", force: :cascade do |t|
    t.integer "qualification_kind_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "label", null: false
    t.string "description", limit: 1023
    t.index ["locale"], name: "index_qualification_kind_translations_on_locale"
    t.index ["qualification_kind_id"], name: "index_qualification_kind_translations_on_qualification_kind_id"
  end

  create_table "qualification_kinds", id: :serial, force: :cascade do |t|
    t.integer "validity"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.datetime "deleted_at", precision: nil
    t.integer "reactivateable"
    t.decimal "required_training_days", precision: 5, scale: 2
  end

  create_table "qualifications", id: :serial, force: :cascade do |t|
    t.integer "person_id", null: false
    t.integer "qualification_kind_id", null: false
    t.date "start_at", null: false
    t.date "finish_at"
    t.string "origin"
    t.date "qualified_at"
    t.index ["person_id"], name: "index_qualifications_on_person_id"
    t.index ["qualification_kind_id"], name: "index_qualifications_on_qualification_kind_id"
  end

  create_table "related_role_types", id: :serial, force: :cascade do |t|
    t.integer "relation_id"
    t.string "role_type", null: false
    t.string "relation_type"
    t.index ["relation_id", "relation_type"], name: "index_related_role_types_on_relation_id_and_relation_type"
    t.index ["role_type"], name: "index_related_role_types_on_role_type"
  end

  create_table "reporting_parameters", id: :serial, force: :cascade do |t|
    t.integer "year", null: false
    t.decimal "vollkosten_le_schwelle1_blockkurs", precision: 12, scale: 2, null: false
    t.decimal "vollkosten_le_schwelle2_blockkurs", precision: 12, scale: 2, null: false
    t.decimal "vollkosten_le_schwelle1_tageskurs", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "vollkosten_le_schwelle2_tageskurs", precision: 12, scale: 2, default: "0.0", null: false
    t.integer "bsv_hours_per_year", null: false
    t.decimal "capital_substrate_exemption", precision: 12, scale: 2, null: false
    t.decimal "capital_substrate_limit", precision: 12, scale: 2, null: false
    t.index ["year"], name: "index_reporting_parameters_on_year", unique: true
  end

  create_table "role_type_orders", force: :cascade do |t|
    t.string "name"
    t.integer "order_weight"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "roles", id: :serial, force: :cascade do |t|
    t.integer "person_id", null: false
    t.integer "group_id", null: false
    t.string "type", null: false
    t.string "label"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.datetime "archived_at", precision: nil
    t.boolean "terminated", default: false, null: false
    t.date "start_on"
    t.date "end_on"
    t.index ["person_id", "group_id"], name: "index_roles_on_person_id_and_group_id"
    t.index ["type"], name: "index_roles_on_type"
  end

  create_table "self_registration_reason_translations", force: :cascade do |t|
    t.bigint "self_registration_reason_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "text", null: false
    t.index ["locale"], name: "index_self_registration_reason_translations_on_locale"
    t.index ["self_registration_reason_id"], name: "index_d351072d2828208df6f5a55e3d6d5f361a7c23ea"
  end

  create_table "self_registration_reasons", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "service_tokens", id: :serial, force: :cascade do |t|
    t.integer "layer_group_id", null: false
    t.string "name", null: false
    t.text "description"
    t.string "token", null: false
    t.datetime "last_access", precision: nil
    t.boolean "people", default: false
    t.boolean "groups", default: false
    t.boolean "events", default: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "invoices", default: false, null: false
    t.boolean "event_participations", default: false, null: false
    t.boolean "mailing_lists", default: false, null: false
    t.string "permission", default: "layer_read", null: false
  end

  create_table "sessions", id: :serial, force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.bigint "person_id"
    t.index ["person_id"], name: "index_sessions_on_person_id"
    t.index ["session_id"], name: "index_sessions_on_session_id"
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "social_accounts", id: :serial, force: :cascade do |t|
    t.string "contactable_type", null: false
    t.integer "contactable_id", null: false
    t.string "name", null: false
    t.string "label"
    t.boolean "public", default: true, null: false
    t.virtual "search_column", type: :tsvector, as: "to_tsvector('simple'::regconfig, COALESCE((name)::text, ''::text))", stored: true
    t.index ["contactable_id", "contactable_type"], name: "index_social_accounts_on_contactable_id_and_contactable_type"
    t.index ["search_column"], name: "social_accounts_search_column_gin_idx", using: :gin
  end

  create_table "subscription_tags", force: :cascade do |t|
    t.boolean "excluded", default: false
    t.integer "subscription_id", null: false
    t.integer "tag_id", null: false
    t.index ["subscription_id"], name: "index_subscription_tags_on_subscription_id"
    t.index ["tag_id"], name: "index_subscription_tags_on_tag_id"
  end

  create_table "subscriptions", id: :serial, force: :cascade do |t|
    t.integer "mailing_list_id", null: false
    t.string "subscriber_type", null: false
    t.integer "subscriber_id", null: false
    t.boolean "excluded", default: false, null: false
    t.index ["mailing_list_id"], name: "index_subscriptions_on_mailing_list_id"
    t.index ["subscriber_id", "subscriber_type"], name: "index_subscriptions_on_subscriber_id_and_subscriber_type"
  end

  create_table "table_displays", id: :serial, force: :cascade do |t|
    t.integer "person_id", null: false
    t.text "selected"
    t.string "table_model_class", null: false
    t.index ["person_id", "table_model_class"], name: "index_table_displays_on_person_id_and_table_model_class", unique: true
  end

  create_table "taggings", id: :serial, force: :cascade do |t|
    t.integer "tag_id"
    t.string "taggable_type"
    t.integer "taggable_id"
    t.string "tagger_type"
    t.integer "tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at", precision: nil
    t.string "hitobito_tooltip"
    t.string "tenant", limit: 128
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
    t.index ["tenant"], name: "index_taggings_on_tenant"
  end

  create_table "tags", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "time_record_employee_pensums", id: :serial, force: :cascade do |t|
    t.integer "time_record_id", null: false
    t.decimal "paragraph_74", precision: 12, scale: 2
    t.decimal "not_paragraph_74", precision: 12, scale: 2
  end

  create_table "time_records", id: :serial, force: :cascade do |t|
    t.integer "group_id", null: false
    t.integer "year", null: false
    t.integer "verwaltung"
    t.integer "beratung"
    t.integer "treffpunkte"
    t.integer "blockkurse"
    t.integer "tageskurse"
    t.integer "jahreskurse"
    t.integer "kontakte_medien"
    t.integer "interviews"
    t.integer "publikationen"
    t.integer "referate"
    t.integer "medienkonferenzen"
    t.integer "informationsveranstaltungen"
    t.integer "sensibilisierungskampagnen"
    t.integer "auskunftserteilung"
    t.integer "kontakte_meinungsbildner"
    t.integer "beratung_medien"
    t.integer "eigene_zeitschriften"
    t.integer "newsletter"
    t.integer "informationsbroschueren"
    t.integer "eigene_webseite"
    t.integer "erarbeitung_instrumente"
    t.integer "erarbeitung_grundlagen"
    t.integer "projekte"
    t.integer "vernehmlassungen"
    t.integer "gremien"
    t.integer "vermittlung_kontakte"
    t.integer "unterstuetzung_selbsthilfeorganisationen"
    t.integer "koordination_selbsthilfe"
    t.integer "treffen_meinungsaustausch"
    t.integer "beratung_fachhilfeorganisationen"
    t.integer "unterstuetzung_behindertenhilfe"
    t.integer "mittelbeschaffung"
    t.integer "allgemeine_auskunftserteilung"
    t.string "type", null: false
    t.integer "total_lufeb_general"
    t.integer "total_lufeb_private"
    t.integer "total_lufeb_specific"
    t.integer "total_lufeb_promoting"
    t.integer "nicht_art_74_leistungen"
    t.integer "unterstuetzung_leitorgane"
    t.integer "freiwilligen_akquisition"
    t.integer "auskuenfte"
    t.integer "medien_zusammenarbeit"
    t.integer "medien_grundlagen"
    t.integer "website"
    t.integer "videos"
    t.integer "social_media"
    t.integer "beratungsmodule"
    t.integer "apps"
    t.integer "total_media"
    t.integer "kurse_grundlagen"
    t.integer "lufeb_grundlagen"
    t.integer "treffpunkte_grundlagen"
    t.index ["group_id", "year", "type"], name: "index_time_records_on_group_id_and_year_and_type", unique: true
  end

  create_table "versions", id: :serial, force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.text "object_changes"
    t.string "main_type"
    t.integer "main_id"
    t.datetime "created_at", precision: nil
    t.string "whodunnit_type", default: "Person", null: false
    t.string "mutation_id"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
    t.index ["main_id", "main_type"], name: "index_versions_on_main_id_and_main_type"
    t.index ["mutation_id"], name: "index_versions_on_mutation_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "calendar_tags", "tags", on_delete: :cascade
  add_foreign_key "group_translations", "groups"
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_openid_requests", "oauth_access_grants", column: "access_grant_id", on_delete: :cascade
  add_foreign_key "people", "self_registration_reasons"
  add_foreign_key "subscription_tags", "subscriptions"
  add_foreign_key "subscription_tags", "tags"
end
