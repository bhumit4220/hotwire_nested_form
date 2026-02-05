# frozen_string_literal: true

module HotwireNestedForm
  module Helpers
    module AddAssociation
      # Generates a link to add nested form fields
      #
      # @param name [String] Link text (or use block)
      # @param form [FormBuilder] Parent form object
      # @param association [Symbol] Association name
      # @param options [Hash] HTML attributes and gem options
      # @yield Block for custom link content
      # @return [String] HTML link element
      #
      # @example Basic usage
      #   <%= link_to_add_association "Add Task", f, :tasks %>
      #
      # @example With block
      #   <%= link_to_add_association f, :tasks do %>
      #     <span>+ Add Task</span>
      #   <% end %>
      #
      def link_to_add_association(name = nil, form = nil, association = nil, options = {}, &)
        # Handle block syntax: link_to_add_association(form, :tasks) { "Add" }
        if block_given?
          options = association || {}
          association = form
          form = name
          name = capture(&)
        end

        raise ArgumentError, 'form is required' unless form
        raise ArgumentError, 'association is required' unless association

        options = options.dup

        # Extract gem-specific options
        partial = options.delete(:partial)
        render_options = options.delete(:render_options) || {}
        wrap_object = options.delete(:wrap_object)
        count = options.delete(:count) || 1
        insertion = options.delete(:insertion) || :before
        target = options.delete(:target)

        # Build the template
        template = build_association_template(
          form,
          association,
          partial: partial,
          render_options: render_options,
          wrap_object: wrap_object
        )

        # Build data attributes
        data = options[:data] || {}
        data[:action] = 'nested-form#add'
        data[:template] = template
        data[:insertion] = insertion
        data[:count] = count if count > 1
        data[:target] = target if target

        options[:data] = data
        options[:href] = '#'

        content_tag(:a, name, options)
      end

      private

      def build_association_template(form, association, partial:, render_options:, wrap_object:)
        # Get the association reflection
        reflection = form.object.class.reflect_on_association(association)
        raise ArgumentError, "Association #{association} not found" unless reflection

        # Build a new object for the association
        new_object = build_association_object(form.object, reflection, wrap_object)

        # Determine partial name
        partial_name = partial || "#{association.to_s.singularize}_fields"

        # Render the fields using fields_for
        # This works with both standard Rails FormBuilder and SimpleForm::FormBuilder
        # SimpleForm overrides fields_for to use simple_fields_for internally
        form.fields_for(association, new_object, child_index: 'NEW_RECORD') do |builder|
          locals = (render_options[:locals] || {}).merge(f: builder)
          render(partial: partial_name, locals: locals)
        end
      end

      def build_association_object(parent, reflection, wrap_object)
        new_object = case reflection.macro
                     when :has_many, :has_and_belongs_to_many
                       reflection.klass.new
                     when :has_one
                       parent.send("build_#{reflection.name}")
                     else
                       reflection.klass.new
                     end

        wrap_object ? wrap_object.call(new_object) : new_object
      end
    end
  end
end
