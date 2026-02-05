# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Removing nested fields", type: :system do
  describe "removing new (unpersisted) fields" do
    it "removes new fields from DOM completely" do
      visit new_project_path

      click_link "Add Task"
      expect(page).to have_css(".nested-fields", count: 1)

      click_link "Remove"
      expect(page).to have_no_css(".nested-fields")
    end

    it "can add, remove, and add again" do
      visit new_project_path

      click_link "Add Task"
      expect(page).to have_css(".nested-fields", count: 1)

      click_link "Remove"
      expect(page).to have_no_css(".nested-fields")

      click_link "Add Task"
      expect(page).to have_css(".nested-fields", count: 1)
    end

    it "removes the correct field when multiple exist" do
      visit new_project_path

      click_link "Add Task"
      sleep 0.01
      click_link "Add Task"

      task_fields = all(".nested-fields")
      within(task_fields[0]) do
        fill_in "Task Name", with: "Keep This"
      end
      within(task_fields[1]) do
        fill_in "Task Name", with: "Delete This"
      end

      # Remove the second task
      within(task_fields[1]) do
        click_link "Remove"
      end

      expect(page).to have_css(".nested-fields", count: 1)
      expect(page).to have_field("Task Name", with: "Keep This")
      expect(page).to have_no_field("Task Name", with: "Delete This")
    end
  end

  describe "removing persisted fields" do
    let!(:project) { Project.create!(name: "Test Project") }
    let!(:task) { project.tasks.create!(name: "Existing Task") }

    it "hides persisted fields instead of removing them" do
      visit edit_project_path(project)

      expect(page).to have_css(".nested-fields", count: 1)

      click_link "Remove"

      # Field is hidden, not removed
      expect(page).to have_css(".nested-fields", count: 1, visible: false)
      expect(page).to have_no_css(".nested-fields", visible: true)
    end

    it "sets _destroy hidden field to true" do
      visit edit_project_path(project)

      click_link "Remove"

      destroy_field = find("input[name*='_destroy']", visible: false)
      expect(destroy_field.value).to eq("true")
    end

    it "destroys record on form submit" do
      visit edit_project_path(project)

      expect(project.tasks.count).to eq(1)

      click_link "Remove"
      click_button "Update Project"

      expect(page).to have_content("Project was successfully updated")
      expect(project.reload.tasks.count).to eq(0)
    end

    it "can remove one persisted task while keeping another" do
      project.tasks.create!(name: "Keep This Task")

      visit edit_project_path(project)

      expect(page).to have_css(".nested-fields", count: 2)

      # Remove the first task (Existing Task)
      within(all(".nested-fields").first) do
        click_link "Remove"
      end

      click_button "Update Project"

      expect(project.reload.tasks.count).to eq(1)
      expect(project.tasks.first.name).to eq("Keep This Task")
    end
  end

  describe "mixed new and persisted fields" do
    let!(:project) { Project.create!(name: "Test Project") }
    let!(:task) { project.tasks.create!(name: "Existing Task") }

    it "can add new task and remove persisted task in same form" do
      visit edit_project_path(project)

      # Remove existing task
      within(".nested-fields") do
        click_link "Remove"
      end

      # Add new task
      click_link "Add Task"
      within(all(".nested-fields", visible: true).first) do
        fill_in "Task Name", with: "New Task"
      end

      click_button "Update Project"

      expect(project.reload.tasks.count).to eq(1)
      expect(project.tasks.first.name).to eq("New Task")
    end
  end
end
