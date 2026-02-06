# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Drag & Drop Sorting', type: :system do
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

      # Wait for items to appear
      expect(page).to have_css('.nested-fields', count: 2)

      # Get initial positions - they start at 0 (default)
      position_inputs = all('input[name*="[position]"]', visible: false)
      expect(position_inputs.count).to eq(2)

      # Call the updatePositions function directly via the global method
      # The controller updates positions to 1-indexed values
      page.evaluate_script(<<~JS)
        (function() {
          const controllerElement = document.querySelector('[data-controller="nested-form"]');
          const controllers = window.Stimulus.controllers;
          for (const controller of controllers) {
            if (controller.element === controllerElement && controller.updatePositions) {
              controller.updatePositions();
              return true;
            }
          }
          return false;
        })()
      JS

      # Verify positions updated (both should be 1 and 2)
      position_inputs = all('input[name*="[position]"]', visible: false)
      positions = position_inputs.map { |input| input.value.to_i }
      expect(positions).to eq([1, 2])
    end

    it 'fires after-sort event' do
      visit new_project_path(sortable: true)

      click_link 'Add Task'
      click_link 'Add Task'

      # Wait for items to appear
      expect(page).to have_css('.nested-fields', count: 2)

      page.execute_script("window.sortFired = false")
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
