# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Min/Max Limits', type: :system do
  describe 'max limit' do
    it 'prevents adding beyond max limit' do
      visit new_project_path(max: 2)

      click_link 'Add Task'
      click_link 'Add Task'

      expect(page).to have_css('.nested-fields', count: 2)

      # Third click should not add
      click_link 'Add Task'
      expect(page).to have_css('.nested-fields', count: 2)
    end

    it 'disables add button when max reached (default behavior)' do
      visit new_project_path(max: 1)

      click_link 'Add Task'

      add_button = find('[data-action*="nested-form#add"]')
      expect(add_button[:disabled]).to eq('true')
    end

    it 'hides add button when behavior is hide' do
      visit new_project_path(max: 1, limit_behavior: 'hide')

      click_link 'Add Task'

      expect(page).not_to have_css('[data-action*="nested-form#add"]', visible: true)
    end

    it 'fires limit-reached event when max reached' do
      visit new_project_path(max: 1)

      click_link 'Add Task'

      # Try to add another - should fire event
      page.execute_script('window.limitReached = false')
      page.execute_script("document.addEventListener('nested-form:limit-reached', () => { window.limitReached = true })")

      find('[data-action*="nested-form#add"]').click

      expect(page.evaluate_script('window.limitReached')).to be true
    end
  end

  describe 'min limit' do
    it 'prevents removing below min limit' do
      visit new_project_path(min: 1)

      click_link 'Add Task'
      expect(page).to have_css('.nested-fields', count: 1)

      # Should not be able to remove
      click_link 'Remove'
      expect(page).to have_css('.nested-fields', count: 1)
    end

    it 'disables remove button when at minimum (default behavior)' do
      visit new_project_path(min: 1)

      click_link 'Add Task'

      remove_button = find('[data-action*="nested-form#remove"]')
      expect(remove_button[:disabled]).to eq('true')
    end

    it 'allows remove when above minimum' do
      visit new_project_path(min: 1)

      click_link 'Add Task'
      click_link 'Add Task'

      expect(page).to have_css('.nested-fields', count: 2)

      # Should allow removing one
      first('[data-action*="nested-form#remove"]').click
      expect(page).to have_css('.nested-fields', count: 1)
    end

    it 'fires minimum-reached event when at min' do
      visit new_project_path(min: 1)

      click_link 'Add Task'

      page.execute_script('window.minReached = false')
      page.execute_script("document.addEventListener('nested-form:minimum-reached', () => { window.minReached = true })")

      find('[data-action*="nested-form#remove"]').click

      expect(page.evaluate_script('window.minReached')).to be true
    end
  end

  describe 'dynamic limits' do
    it 'respects dynamically changed max limit' do
      visit new_project_path(max: 1)

      click_link 'Add Task'
      expect(page).to have_css('.nested-fields', count: 1)

      # Change max dynamically
      page.execute_script("document.querySelector('[data-controller=\"nested-form\"]').dataset.nestedFormMaxValue = 3")

      click_link 'Add Task'
      click_link 'Add Task'

      expect(page).to have_css('.nested-fields', count: 3)
    end
  end
end
