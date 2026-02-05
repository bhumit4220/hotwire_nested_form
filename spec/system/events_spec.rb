# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'JavaScript events', type: :system do
  describe 'before-add event' do
    it 'dispatches nested-form:before-add event when adding' do
      visit new_project_path

      # Set up event listener that marks when event fires
      page.execute_script(<<~JS)
        document.addEventListener("nested-form:before-add", function(e) {
          window.beforeAddFired = true;
          window.beforeAddDetail = e.detail;
        });
      JS

      click_link 'Add Task'

      result = page.evaluate_script('window.beforeAddFired')
      expect(result).to be true
    end

    it 'provides wrapper element in event detail' do
      visit new_project_path

      page.execute_script(<<~JS)
        document.addEventListener("nested-form:before-add", function(e) {
          window.wrapperClass = e.detail.wrapper ? e.detail.wrapper.className : null;
        });
      JS

      click_link 'Add Task'

      result = page.evaluate_script('window.wrapperClass')
      expect(result).to include('nested-fields')
    end

    it 'can cancel add with preventDefault' do
      visit new_project_path

      page.execute_script(<<~JS)
        document.addEventListener("nested-form:before-add", function(e) {
          e.preventDefault();
        });
      JS

      click_link 'Add Task'

      # Should not add any fields because event was cancelled
      expect(page).to have_no_css('.nested-fields')
    end
  end

  describe 'after-add event' do
    it 'dispatches nested-form:after-add event after adding' do
      visit new_project_path

      page.execute_script(<<~JS)
        document.addEventListener("nested-form:after-add", function(e) {
          window.afterAddFired = true;
        });
      JS

      click_link 'Add Task'

      result = page.evaluate_script('window.afterAddFired')
      expect(result).to be true
    end

    it 'fires after-add only after fields are actually added' do
      visit new_project_path

      page.execute_script(<<~JS)
        window.fieldCountAtEvent = 0;
        document.addEventListener("nested-form:after-add", function(e) {
          window.fieldCountAtEvent = document.querySelectorAll('.nested-fields').length;
        });
      JS

      click_link 'Add Task'

      result = page.evaluate_script('window.fieldCountAtEvent')
      expect(result).to eq(1)
    end
  end

  describe 'before-remove event' do
    it 'dispatches nested-form:before-remove event when removing' do
      visit new_project_path

      click_link 'Add Task'

      page.execute_script(<<~JS)
        document.addEventListener("nested-form:before-remove", function(e) {
          window.beforeRemoveFired = true;
        });
      JS

      click_link 'Remove'

      result = page.evaluate_script('window.beforeRemoveFired')
      expect(result).to be true
    end

    it 'can cancel remove with preventDefault' do
      visit new_project_path

      click_link 'Add Task'
      expect(page).to have_css('.nested-fields', count: 1)

      page.execute_script(<<~JS)
        document.addEventListener("nested-form:before-remove", function(e) {
          e.preventDefault();
        });
      JS

      click_link 'Remove'

      # Fields should still be there because remove was cancelled
      expect(page).to have_css('.nested-fields', count: 1)
    end
  end

  describe 'after-remove event' do
    it 'dispatches nested-form:after-remove event after removing' do
      visit new_project_path

      click_link 'Add Task'

      page.execute_script(<<~JS)
        document.addEventListener("nested-form:after-remove", function(e) {
          window.afterRemoveFired = true;
        });
      JS

      click_link 'Remove'

      result = page.evaluate_script('window.afterRemoveFired')
      expect(result).to be true
    end
  end

  describe 'event order' do
    it 'fires before-add before after-add' do
      visit new_project_path

      page.execute_script(<<~JS)
        window.eventOrder = [];
        document.addEventListener("nested-form:before-add", function(e) {
          window.eventOrder.push("before-add");
        });
        document.addEventListener("nested-form:after-add", function(e) {
          window.eventOrder.push("after-add");
        });
      JS

      click_link 'Add Task'

      result = page.evaluate_script('window.eventOrder')
      expect(result).to eq(%w[before-add after-add])
    end

    it 'fires before-remove before after-remove' do
      visit new_project_path

      click_link 'Add Task'

      page.execute_script(<<~JS)
        window.eventOrder = [];
        document.addEventListener("nested-form:before-remove", function(e) {
          window.eventOrder.push("before-remove");
        });
        document.addEventListener("nested-form:after-remove", function(e) {
          window.eventOrder.push("after-remove");
        });
      JS

      click_link 'Remove'

      result = page.evaluate_script('window.eventOrder')
      expect(result).to eq(%w[before-remove after-remove])
    end
  end
end
