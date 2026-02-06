# frozen_string_literal: true

ActiveRecord::Schema.define(version: 1) do
  create_table "projects", force: :cascade do |t|
    t.string "name", null: false
    t.timestamps
  end

  create_table "tasks", force: :cascade do |t|
    t.string "name", null: false
    t.integer "project_id", null: false
    t.integer "position", default: 0
    t.timestamps
    t.index ["project_id"], name: "index_tasks_on_project_id"
  end

  add_foreign_key "tasks", "projects"
end
