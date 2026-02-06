# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Accessibility', type: :system do
  it 'sets role="group" on the controller element' do
    visit new_project_path

    controller_div = find('[data-controller="nested-form"]')
    expect(controller_div['role']).to eq('group')
  end

  it 'sets default aria-label on the controller element' do
    visit new_project_path

    controller_div = find('[data-controller="nested-form"]')
    expect(controller_div['aria-label']).to eq('Nested form fields')
  end

  it 'creates a live region for screen reader announcements' do
    visit new_project_path

    expect(page).to have_css('.nested-form-live-region[aria-live="polite"]', visible: :all)
  end

  it 'focuses the first input after adding an item' do
    visit new_project_path

    click_link 'Add Task'
    sleep 0.1

    active_element_tag = page.evaluate_script('document.activeElement.tagName')
    active_element_type = page.evaluate_script('document.activeElement.type')
    expect(active_element_tag).to eq('INPUT')
    expect(active_element_type).to eq('text')
  end

  it 'focuses the add button after removing an item' do
    visit new_project_path

    click_link 'Add Task'
    sleep 0.1

    click_link 'Remove'
    sleep 0.1

    active_element_text = page.evaluate_script('document.activeElement.textContent')
    expect(active_element_text).to eq('Add Task')
  end

  it 'announces when an item is added' do
    visit new_project_path

    click_link 'Add Task'
    sleep 0.1

    live_region = find('.nested-form-live-region', visible: :all)
    expect(live_region.text(:all)).to match(/Item \d+ added/)
  end

  it 'announces when an item is removed' do
    visit new_project_path

    click_link 'Add Task'
    sleep 0.1

    click_link 'Remove'
    sleep 0.1

    live_region = find('.nested-form-live-region', visible: :all)
    expect(live_region.text(:all)).to match(/Item removed/)
  end

  it 'cleans up live region on disconnect' do
    visit new_project_path

    expect(page).to have_css('.nested-form-live-region', visible: :all)

    # Navigate away to trigger disconnect
    visit root_path

    # Live region from previous page should not be present
    expect(page).to have_no_css('.nested-form-live-region', visible: :all)
  end
end
