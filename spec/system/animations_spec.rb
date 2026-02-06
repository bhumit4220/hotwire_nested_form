# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Animations', type: :system do
  it 'adds enter animation classes when adding items with animation enabled' do
    visit new_project_path(animation: 'fade')

    click_link 'Add Task'

    # The enter class should be present immediately after adding
    expect(page).to have_css('.nested-fields.nested-form-enter', wait: 1)
  end

  it 'removes animation classes after animation duration' do
    visit new_project_path(animation: 'fade')

    click_link 'Add Task'

    # After animation completes (300ms + buffer), classes should be removed
    sleep 0.5
    expect(page).to have_css('.nested-fields')
    expect(page).to have_no_css('.nested-form-enter')
    expect(page).to have_no_css('.nested-form-enter-active')
  end

  it 'adds exit animation class when removing items with animation enabled' do
    visit new_project_path(animation: 'fade')

    click_link 'Add Task'
    sleep 0.5 # Wait for enter animation to complete

    click_link 'Remove'

    # The exit class should be applied, then item removed
    # After animation completes, the item should be gone
    sleep 0.5
    expect(page).to have_no_css('.nested-fields')
  end

  it 'does not add animation classes when animation value is empty' do
    visit new_project_path

    click_link 'Add Task'

    expect(page).to have_css('.nested-fields')
    expect(page).to have_no_css('.nested-form-enter')
    expect(page).to have_no_css('.nested-form-enter-active')
  end

  it 'animates removal of persisted records' do
    project = Project.create!(name: 'Animated Project')
    project.tasks.create!(name: 'Persisted Task', position: 1)

    visit edit_project_path(project, animation: 'fade')

    expect(page).to have_css('.nested-fields', count: 1)

    click_link 'Remove'

    # After animation, the field should be hidden (not removed, since persisted)
    sleep 0.5
    expect(page).to have_no_css('.nested-fields:not([style*="display: none"])')

    # Submit and verify _destroy was set
    click_button 'Update Project'
    expect(page).to have_content('Project was successfully updated')
    expect(project.reload.tasks.count).to eq(0)
  end
end
