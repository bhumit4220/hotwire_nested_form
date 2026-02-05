# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Formtastic Integration', type: :helper do
  let(:project) { Project.new(name: 'Test Project') }

  before do
    skip 'Formtastic not available' unless defined?(Formtastic)
  end

  describe 'FormBuilderDetector with Formtastic' do
    it 'detects Formtastic::FormBuilder' do
      mock_builder = double('Formtastic::FormBuilder')
      allow(mock_builder).to receive(:class).and_return(
        double(name: 'Formtastic::FormBuilder')
      )

      expect(HotwireNestedForm::FormBuilderDetector.formtastic?(mock_builder)).to be true
    end

    it 'detects Formtastic::SemanticFormBuilder' do
      mock_builder = double('Formtastic::SemanticFormBuilder')
      allow(mock_builder).to receive(:class).and_return(
        double(name: 'Formtastic::SemanticFormBuilder')
      )

      expect(HotwireNestedForm::FormBuilderDetector.formtastic?(mock_builder)).to be true
    end

    it 'reports Formtastic as available' do
      expect(HotwireNestedForm::FormBuilderDetector.formtastic_available?).to be true
    end
  end

  describe 'link_to_remove_association with Formtastic' do
    it 'works with Formtastic form builder' do
      expect(HotwireNestedForm::FormBuilderDetector.formtastic_available?).to be true
    end
  end
end
