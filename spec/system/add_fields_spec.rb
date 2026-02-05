# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Adding nested fields', type: :system do
  it 'adds new fields when clicking add link' do
    visit new_project_path

    expect(page).to have_no_css('.nested-fields')

    click_link 'Add Task'

    expect(page).to have_css('.nested-fields', count: 1)
  end

  it 'adds multiple fields with multiple clicks' do
    visit new_project_path

    click_link 'Add Task'
    click_link 'Add Task'
    click_link 'Add Task'

    expect(page).to have_css('.nested-fields', count: 3)
  end

  it 'generates unique IDs for each added field' do
    visit new_project_path

    click_link 'Add Task'
    sleep 0.01 # Ensure different timestamp
    click_link 'Add Task'

    name_fields = all("input[name*='[tasks_attributes]'][name*='[name]']")
    expect(name_fields.size).to eq(2)

    # Extract the unique IDs from the name attributes
    ids = name_fields.map { |f| f[:name][/\[(\d+)\]/, 1] }
    expect(ids.uniq.size).to eq(2)
  end

  it 'inserts fields before the add link by default' do
    visit new_project_path

    click_link 'Add Task'

    # The nested-fields div should appear before the add link
    page_html = page.body
    nested_fields_pos = page_html.index('class="nested-fields"')
    add_link_pos = page_html.index('class="add-task-link"')

    expect(nested_fields_pos).to be < add_link_pos
  end

  it 'submits form with nested attributes and saves to database' do
    visit new_project_path

    fill_in 'Name', with: 'My Test Project'
    click_link 'Add Task'

    # Fill in the task name field
    within '.nested-fields' do
      fill_in 'Task Name', with: 'First Task'
    end

    click_button 'Create Project'

    # Verify redirect and flash message
    expect(page).to have_content('Project was successfully created')

    # Verify database records
    project = Project.last
    expect(project.name).to eq('My Test Project')
    expect(project.tasks.count).to eq(1)
    expect(project.tasks.first.name).to eq('First Task')
  end

  it 'can add and save multiple tasks' do
    visit new_project_path

    fill_in 'Name', with: 'Multi-task Project'

    click_link 'Add Task'
    sleep 0.01
    click_link 'Add Task'

    task_fields = all('.nested-fields')
    within(task_fields[0]) do
      fill_in 'Task Name', with: 'Task One'
    end
    within(task_fields[1]) do
      fill_in 'Task Name', with: 'Task Two'
    end

    click_button 'Create Project'

    project = Project.last
    expect(project.tasks.count).to eq(2)
    expect(project.tasks.pluck(:name)).to contain_exactly('Task One', 'Task Two')
  end
end
