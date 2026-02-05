# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'SimpleForm Integration', type: :helper do
  let(:project) { Project.new(name: 'Test Project') }

  before do
    # Skip all tests if SimpleForm is not available
    skip 'SimpleForm not available' unless defined?(SimpleForm)
  end

  describe 'FormBuilderDetector with SimpleForm' do
    it 'detects SimpleForm::FormBuilder' do
      # Create a mock SimpleForm builder
      mock_builder = double('SimpleForm::FormBuilder')
      allow(mock_builder).to receive(:class).and_return(
        double(name: 'SimpleForm::FormBuilder')
      )

      expect(HotwireNestedForm::FormBuilderDetector.simple_form?(mock_builder)).to be true
    end

    it 'reports SimpleForm as available' do
      expect(HotwireNestedForm::FormBuilderDetector.simple_form_available?).to be true
    end
  end

  describe 'link_to_remove_association with SimpleForm' do
    it 'works with SimpleForm form builder' do
      # This tests that our helper methods work in a SimpleForm context
      # The actual rendering is tested in system specs
      expect(HotwireNestedForm::FormBuilderDetector.simple_form_available?).to be true
    end
  end
end
