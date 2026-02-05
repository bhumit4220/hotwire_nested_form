# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HotwireNestedForm::Helpers::AddAssociation, type: :helper do
  let(:project) { Project.new(name: 'Test Project') }

  describe '#link_to_add_association' do
    describe 'argument validation' do
      it 'raises ArgumentError when form is nil' do
        expect do
          helper.link_to_add_association('Add Task', nil, :tasks)
        end.to raise_error(ArgumentError, 'form is required')
      end

      it 'raises ArgumentError when association is nil' do
        form_builder = nil
        helper.form_with(model: project, url: '/projects') { |f| form_builder = f }
        expect do
          helper.link_to_add_association('Add Task', form_builder, nil)
        end.to raise_error(ArgumentError, 'association is required')
      end

      it 'raises ArgumentError for invalid association' do
        form_builder = nil
        helper.form_with(model: project, url: '/projects') { |f| form_builder = f }
        expect do
          helper.link_to_add_association('Add Item', form_builder, :invalid_association)
        end.to raise_error(ArgumentError, /Association invalid_association not found/)
      end
    end

    # Full rendering tests are done in system specs since they require
    # proper controller context and view paths

    describe 'SimpleForm compatibility' do
      it 'detects SimpleForm builder using FormBuilderDetector' do
        # Verify FormBuilderDetector correctly identifies SimpleForm builders
        mock_simple_form_builder = double('SimpleForm::FormBuilder')
        allow(mock_simple_form_builder).to receive(:class).and_return(
          double(name: 'SimpleForm::FormBuilder')
        )

        expect(HotwireNestedForm::FormBuilderDetector.simple_form?(mock_simple_form_builder)).to be true
      end

      it 'detects standard Rails form builder' do
        form_builder = nil
        helper.form_with(model: project, url: '/projects') { |f| form_builder = f }

        expect(HotwireNestedForm::FormBuilderDetector.simple_form?(form_builder)).to be false
      end
    end
  end
end
