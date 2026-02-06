# frozen_string_literal: true

ActiveRecord::Schema.define(version: 2) do
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

  create_table "subtasks", force: :cascade do |t|
    t.string "name", null: false
    t.integer "task_id", null: false
    t.timestamps
    t.index ["task_id"], name: "index_subtasks_on_task_id"
  end

  add_foreign_key "tasks", "projects"
  add_foreign_key "subtasks", "tasks"
end
