# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Duplicate', type: :system do
  it 'duplicates a nested item with same field values' do
    visit new_project_path

    click_link 'Add Task'
    fill_in 'Task Name', with: 'Original Task'

    click_link 'Duplicate'
    expect(page).to have_css('.nested-fields', count: 2)

    task_inputs = all("input[name*='[tasks_attributes]'][name*='[name]']")
    expect(task_inputs.map(&:value)).to eq(['Original Task', 'Original Task'])
  end

  it 'generates a different index for the duplicated item' do
    visit new_project_path

    click_link 'Add Task'
    fill_in 'Task Name', with: 'Task A'

    click_link 'Duplicate'

    task_inputs = all("input[name*='[tasks_attributes]'][name*='[name]']")
    # Extract the index from each name attribute (e.g., project[tasks_attributes][123][name])
    indices = task_inputs.map { |input| input[:name].match(/\[(\d+)\]/)[1] }
    expect(indices.uniq.length).to eq(2)
  end

  it 'clears the id field so Rails creates a new record' do
    project = Project.create!(name: 'Test Project')
    project.tasks.create!(name: 'Persisted Task', position: 1)

    visit edit_project_path(project)

    expect(page).to have_css('.nested-fields', count: 1)

    click_link 'Duplicate'
    expect(page).to have_css('.nested-fields', count: 2)

    # The duplicated item should not have an id hidden field
    nested_fields = all('.nested-fields')
    clone = nested_fields.last
    id_inputs = clone.all("input[name*='[id]'][type='hidden']", visible: :all)
    expect(id_inputs).to be_empty
  end

  it 'respects max limit when duplicating' do
    visit new_project_path(max: 2)

    click_link 'Add Task'
    sleep 0.01
    click_link 'Add Task'

    expect(page).to have_css('.nested-fields', count: 2)

    # Duplicate should not work since we're at max
    click_link 'Duplicate', match: :first
    expect(page).to have_css('.nested-fields', count: 2)
  end

  it 'fires before-duplicate event that is cancelable' do
    visit new_project_path

    click_link 'Add Task'
    fill_in 'Task Name', with: 'Original'

    # Add event listener that cancels the duplicate
    page.execute_script(<<~JS)
      document.querySelector('[data-controller="nested-form"]')
        .addEventListener('nested-form:before-duplicate', (e) => {
          e.preventDefault()
          window.__duplicateCancelled = true
        })
    JS

    click_link 'Duplicate'

    cancelled = page.evaluate_script('window.__duplicateCancelled')
    expect(cancelled).to be true
    expect(page).to have_css('.nested-fields', count: 1)
  end

  it 'saves duplicated item as a new record in the database' do
    visit new_project_path

    fill_in 'Name', with: 'Dup Project'

    click_link 'Add Task'
    fill_in 'Task Name', with: 'First Task'

    click_link 'Duplicate'

    click_button 'Create Project'

    expect(page).to have_content('Project was successfully created')
    project = Project.last
    expect(project.tasks.count).to eq(2)
    expect(project.tasks.pluck(:name)).to eq(['First Task', 'First Task'])
  end

  it 'announces duplication for screen readers' do
    visit new_project_path

    click_link 'Add Task'
    sleep 0.1

    click_link 'Duplicate'
    sleep 0.1

    live_region = find('.nested-form-live-region', visible: :all)
    expect(live_region.text(:all)).to eq('Item duplicated.')
  end
end
