# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Deep Nesting', type: :system do
  it 'adds a subtask inside a task' do
    visit deep_new_projects_path

    click_link 'Add Task'
    expect(page).to have_css('.nested-fields', count: 1)

    click_link 'Add Subtask'
    # Should have 2 nested-fields: 1 task + 1 subtask
    expect(page).to have_css('.nested-fields', count: 2)
  end

  it 'removes a subtask without affecting the parent task' do
    visit deep_new_projects_path

    click_link 'Add Task'
    click_link 'Add Subtask'
    expect(page).to have_css('.nested-fields', count: 2)

    click_link 'Remove Subtask'
    # Only the task should remain
    expect(page).to have_css('.nested-fields', count: 1)
    expect(page).to have_link('Add Subtask')
  end

  it 'adds multiple subtasks to a single task' do
    visit deep_new_projects_path

    click_link 'Add Task'
    click_link 'Add Subtask'
    sleep 0.01
    click_link 'Add Subtask'

    # 1 task + 2 subtasks
    expect(page).to have_css('.nested-fields', count: 3)
  end

  it 'generates correct form field names for subtasks' do
    visit deep_new_projects_path

    click_link 'Add Task'
    click_link 'Add Subtask'

    subtask_name_field = find("input[name*='[subtasks_attributes]'][name*='[name]']")
    expect(subtask_name_field[:name]).to match(
      /project\[tasks_attributes\]\[\d+\]\[subtasks_attributes\]\[\d+\]\[name\]/
    )
  end

  it 'uses unique placeholders per association level' do
    visit deep_new_projects_path

    # The add task button should have a task-specific placeholder
    add_task_link = find('.add-task-link')
    expect(add_task_link['data-placeholder']).to eq('NEW_TASK_RECORD')

    click_link 'Add Task'

    # The add subtask button should have a subtask-specific placeholder
    add_subtask_link = find('.add-subtask-link')
    expect(add_subtask_link['data-placeholder']).to eq('NEW_SUBTASK_RECORD')
  end

  it 'submits form with multi-level nesting and saves correctly' do # rubocop:disable RSpec/MultipleExpectations
    visit deep_new_projects_path

    fill_in 'Name', with: 'Deep Project'

    click_link 'Add Task'
    within(all('.nested-fields').first) do
      fill_in 'Task Name', with: 'Parent Task'
    end

    click_link 'Add Subtask'
    within(all('.nested-fields').last) do
      fill_in 'Subtask', with: 'Child Subtask'
    end

    click_button 'Create Project'

    expect(page).to have_content('Project was successfully created')

    project = Project.last
    expect(project.name).to eq('Deep Project')
    expect(project.tasks.count).to eq(1)
    expect(project.tasks.first.name).to eq('Parent Task')
    expect(project.tasks.first.subtasks.count).to eq(1)
    expect(project.tasks.first.subtasks.first.name).to eq('Child Subtask')
  end

  it 'preserves parent task fields when adding subtasks' do
    visit deep_new_projects_path

    click_link 'Add Task'
    fill_in 'Task Name', with: 'My Task'

    click_link 'Add Subtask'

    # The task name should still be filled in
    task_name_field = find("input[name*='[tasks_attributes]'][name*='[name]']:not([name*='subtasks'])")
    expect(task_name_field.value).to eq('My Task')
  end
end
