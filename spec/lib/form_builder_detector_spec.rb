# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HotwireNestedForm::FormBuilderDetector do
  describe '.simple_form?' do
    context 'when form builder is SimpleForm::FormBuilder' do
      it 'returns true' do
        # Mock a SimpleForm builder
        mock_builder = double('SimpleForm::FormBuilder')
        allow(mock_builder).to receive(:class).and_return(
          double(name: 'SimpleForm::FormBuilder', ancestors: [])
        )

        expect(described_class.simple_form?(mock_builder)).to be true
      end
    end

    context 'when form builder is standard Rails FormBuilder' do
      it 'returns false' do
        mock_builder = double('ActionView::Helpers::FormBuilder')
        allow(mock_builder).to receive(:class).and_return(
          double(name: 'ActionView::Helpers::FormBuilder', ancestors: [])
        )

        expect(described_class.simple_form?(mock_builder)).to be false
      end
    end
  end

  describe '.simple_form_available?' do
    it 'returns true when SimpleForm is defined' do
      stub_const('SimpleForm', Module.new)
      expect(described_class.simple_form_available?).to be true
    end

    it 'returns false when SimpleForm is not defined' do
      hide_const('SimpleForm') if defined?(SimpleForm)
      expect(described_class.simple_form_available?).to be false
    end
  end
end
