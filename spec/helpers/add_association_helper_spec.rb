# frozen_string_literal: true

require "spec_helper"

RSpec.describe HotwireNestedForm::Helpers::AddAssociation, type: :helper do
  let(:project) { Project.new(name: "Test Project") }

  describe "#link_to_add_association" do
    describe "argument validation" do
      it "raises ArgumentError when form is nil" do
        expect {
          helper.link_to_add_association("Add Task", nil, :tasks)
        }.to raise_error(ArgumentError, "form is required")
      end

      it "raises ArgumentError when association is nil" do
        form_builder = nil
        helper.form_with(model: project, url: "/projects") { |f| form_builder = f }
        expect {
          helper.link_to_add_association("Add Task", form_builder, nil)
        }.to raise_error(ArgumentError, "association is required")
      end

      it "raises ArgumentError for invalid association" do
        form_builder = nil
        helper.form_with(model: project, url: "/projects") { |f| form_builder = f }
        expect {
          helper.link_to_add_association("Add Item", form_builder, :invalid_association)
        }.to raise_error(ArgumentError, /Association invalid_association not found/)
      end
    end

    # Full rendering tests are done in system specs since they require
    # proper controller context and view paths
  end
end
