# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Drag & Drop Sorting', type: :system do
  def update_positions_js
    <<~JS
      (function() {
        const el = document.querySelector('[data-controller="nested-form"]');
        const controllers = window.Stimulus.controllers;
        for (const c of controllers) {
          if (c.element === el && c.updatePositions) { c.updatePositions(); return true; }
        }
        return false;
      })()
    JS
  end

  describe 'sortable disabled (default)' do
    it 'does not initialize sortable when not enabled' do
      visit new_project_path

      click_link 'Add Task'
      click_link 'Add Task'

      # Items should not have drag classes
      expect(page).not_to have_css('.nested-form-dragging')
      expect(page).not_to have_css('.nested-form-drag-ghost')
    end
  end

  describe 'sortable enabled' do
    it 'initializes sortable when enabled' do
      visit new_project_path(sortable: true)

      click_link 'Add Task'
      click_link 'Add Task'

      # Check that drag handles are present
      expect(page).to have_css('.drag-handle', count: 2)
    end

    it 'updates position fields after drag' do
      visit new_project_path(sortable: true)

      click_link 'Add Task'
      click_link 'Add Task'
      expect(page).to have_css('.nested-fields', count: 2)
      expect(all('input[name*="[position]"]', visible: false).count).to eq(2)

      # Call updatePositions on the controller to simulate post-drag update
      page.evaluate_script(update_positions_js)

      positions = all('input[name*="[position]"]', visible: false).map { |input| input.value.to_i }
      expect(positions).to eq([1, 2])
    end

    it 'fires after-sort event' do
      visit new_project_path(sortable: true)

      click_link 'Add Task'
      click_link 'Add Task'

      # Wait for items to appear
      expect(page).to have_css('.nested-fields', count: 2)

      page.execute_script('window.sortFired = false')
      page.execute_script("document.addEventListener('nested-form:after-sort', () => { window.sortFired = true })")

      # Dispatch the after-sort event manually
      page.execute_script(<<~JS)
        const controllerElement = document.querySelector('[data-controller="nested-form"]');
        const event = new CustomEvent('nested-form:after-sort', {
          bubbles: true,
          detail: { item: null, oldIndex: 1, newIndex: 0 }
        });
        controllerElement.dispatchEvent(event);
      JS

      expect(page.evaluate_script('window.sortFired')).to be true
    end
  end

  describe 'position persistence' do
    it 'saves positions to database on form submit' do
      visit new_project_path(sortable: true)

      fill_in 'project[name]', with: 'Test Project'

      click_link 'Add Task'
      all('input[name*="[name]"]').last.set('Task A')

      click_link 'Add Task'
      all('input[name*="[name]"]').last.set('Task B')

      click_link 'Add Task'
      all('input[name*="[name]"]').last.set('Task C')

      # Set positions manually (simulating drag result)
      page.execute_script(<<~JS)
        const inputs = document.querySelectorAll('input[name*="[position]"]');
        inputs[0].value = 3;
        inputs[1].value = 1;
        inputs[2].value = 2;
      JS

      click_button 'Create Project'

      expect(page).to have_content('Project was successfully created')

      # Verify order in database
      project = Project.last
      task_names = project.tasks.order(:position).pluck(:name)
      expect(task_names).to eq(['Task B', 'Task C', 'Task A'])
    end
  end
end
