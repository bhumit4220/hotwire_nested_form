# frozen_string_literal: true

require "spec_helper"

RSpec.describe HotwireNestedForm::Helpers::RemoveAssociation, type: :helper do
  let(:project) { Project.create!(name: "Test Project") }
  let(:task) { project.tasks.create!(name: "Task 1") }
  let(:new_task) { project.tasks.build(name: "New Task") }

  describe "#link_to_remove_association" do
    context "with a new (unpersisted) record" do
      it "generates a link with data-action attribute" do
        html = nested_form_link(project, new_task)
        expect(html).to include('data-action="nested-form#remove"')
      end

      it "generates a link with href='#'" do
        html = nested_form_link(project, new_task)
        expect(html).to include('href="#"')
      end

      it "includes the link text" do
        html = nested_form_link(project, new_task)
        expect(html).to include("Remove")
      end

      it "does not include _destroy hidden field for new records" do
        html = nested_form_link(project, new_task)
        expect(html).not_to include("_destroy")
      end
    end

    context "with a persisted record" do
      it "generates _destroy hidden field" do
        html = nested_form_link(project, task)
        expect(html).to include("_destroy")
        expect(html).to include('value="false"')
      end

      it "generates a link with data-action attribute" do
        html = nested_form_link(project, task)
        expect(html).to include('data-action="nested-form#remove"')
      end
    end

    it "passes HTML options to the link" do
      html = nested_form_link(project, task, class: "btn-danger", id: "remove-btn")
      expect(html).to include('class="btn-danger"')
      expect(html).to include('id="remove-btn"')
    end

    it "raises ArgumentError when form is nil" do
      expect {
        helper.link_to_remove_association("Remove", nil)
      }.to raise_error(ArgumentError, "form is required")
    end
  end

  private

  def nested_form_link(parent, child, options = {})
    result = nil
    helper.form_with(model: parent, url: "/projects/#{parent.id || 1}") do |f|
      f.fields_for(:tasks, child) do |tf|
        result = helper.link_to_remove_association("Remove", tf, options)
      end
    end
    result
  end
end
