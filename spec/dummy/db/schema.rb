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

ActiveRecord::Schema.define(version: 20130922172200) do

  create_table "iox_activities", force: true do |t|
    t.integer  "user_id"
    t.integer  "obj_id"
    t.string   "obj_type"
    t.string   "obj_name"
    t.string   "obj_path"
    t.string   "recipient_name"
    t.string   "recipient_path"
    t.string   "action"
    t.string   "icon_class"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "iox_cloud_containers", force: true do |t|
    t.string   "name"
    t.integer  "access",                default: 1
    t.date     "public_access_expires"
    t.string   "public_key"
    t.datetime "created_at"
    t.integer  "updated_by"
    t.datetime "updated_at"
  end

  create_table "iox_cloud_stats", force: true do |t|
    t.string   "ip_addr"
    t.string   "user_agent"
    t.string   "os"
    t.integer  "views",              default: 1
    t.integer  "visits",             default: 1
    t.string   "lang"
    t.integer  "cloud_container_id"
    t.date     "day"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "iox_privileges", force: true do |t|
    t.boolean  "can_write",  default: false
    t.boolean  "can_delete", default: false
    t.boolean  "can_share",  default: false
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "iox_translations", force: true do |t|
    t.string   "locale",           default: "default"
    t.string   "template",         default: "default"
    t.string   "title"
    t.string   "subtitle"
    t.string   "meta_description"
    t.string   "meta_keywords"
    t.text     "content"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "deleted_by"
    t.integer  "webbit_id"
    t.integer  "webpage_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "iox_users", force: true do |t|
    t.string   "username"
    t.string   "firstname"
    t.string   "lastname"
    t.string   "phone"
    t.string   "time_zone"
    t.string   "lang"
    t.string   "email"
    t.datetime "last_login_at"
    t.datetime "last_request_at"
    t.string   "last_request_ip"
    t.string   "last_login_ip"
    t.text     "settings"
    t.boolean  "suspended",                    default: false
    t.string   "roles",                        default: "---\n- user\n"
    t.string   "password_digest"
    t.string   "confirmation_key"
    t.datetime "confirmation_key_valid_until"
    t.string   "registration_ip"
    t.integer  "login_failures"
    t.datetime "last_login_failure"
    t.string   "last_login_failure_ip"
    t.datetime "last_activities_call"
    t.boolean  "registration_completed"
    t.string   "can_write_apps"
    t.string   "can_read_apps"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "iox_webbits", force: true do |t|
    t.string   "name"
    t.string   "plugin_type"
    t.string   "css_classes"
    t.integer  "webpage_id"
    t.string   "category"
    t.string   "icon",               default: "icon-align-left"
    t.datetime "deleted_at"
    t.integer  "parent_id"
    t.integer  "links_to_webbit_id"
    t.integer  "position",           default: 999
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "iox_webfiles", force: true do |t|
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.string   "name"
    t.string   "description"
    t.string   "content_type"
    t.string   "copyright"
    t.datetime "orig_date"
    t.boolean  "published",         default: true
    t.integer  "webpage_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "iox_webpage_stats", force: true do |t|
    t.string   "ip_addr"
    t.string   "user_agent"
    t.string   "os"
    t.integer  "views",      default: 1
    t.integer  "visits",     default: 1
    t.string   "lang"
    t.integer  "webpage_id"
    t.date     "day"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "iox_webpages", force: true do |t|
    t.string   "name"
    t.string   "slug"
    t.string   "template"
    t.integer  "master_id"
    t.integer  "parent_id"
    t.integer  "updated_by"
    t.integer  "created_by"
    t.boolean  "published",       default: false
    t.integer  "position",        default: 99
    t.datetime "deleted_at"
    t.string   "type"
    t.boolean  "show_in_menu",    default: true
    t.boolean  "show_in_sitemap", default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
