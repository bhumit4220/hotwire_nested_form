# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HotwireNestedForm::Helpers::DuplicateAssociation, type: :helper do
  let(:project) { Project.create!(name: 'Test Project') }
  let(:task) { project.tasks.create!(name: 'Task 1') }

  describe '#link_to_duplicate_association' do
    it 'generates a link with data-action attribute' do
      html = duplicate_link(project, task)
      expect(html).to include('data-action="nested-form#duplicate"')
    end

    it "generates a link with href='#'" do
      html = duplicate_link(project, task)
      expect(html).to include('href="#"')
    end

    it 'includes the link text' do
      html = duplicate_link(project, task)
      expect(html).to include('Duplicate')
    end

    it 'passes HTML options to the link' do
      html = duplicate_link(project, task, class: 'btn-copy', id: 'dup-btn')
      expect(html).to include('class="btn-copy"')
      expect(html).to include('id="dup-btn"')
    end

    it 'raises ArgumentError when form is nil' do
      expect do
        helper.link_to_duplicate_association('Duplicate', nil)
      end.to raise_error(ArgumentError, 'form is required')
    end
  end

  private

  def duplicate_link(parent, child, options = {})
    result = nil
    helper.form_with(model: parent, url: "/projects/#{parent.id || 1}") do |f|
      f.fields_for(:tasks, child) do |tf|
        result = helper.link_to_duplicate_association('Duplicate', tf, options)
      end
    end
    result
  end
end
