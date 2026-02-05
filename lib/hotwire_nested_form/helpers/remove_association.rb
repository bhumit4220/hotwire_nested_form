# frozen_string_literal: true

module HotwireNestedForm
  module Helpers
    module RemoveAssociation
      # Generates a link to remove nested form fields
      #
      # @param name [String] Link text (or use block)
      # @param form [FormBuilder] Nested form object
      # @param options [Hash] HTML attributes and gem options
      # @yield Block for custom link content
      # @return [String] HTML link element + hidden _destroy field
      #
      # @example Basic usage
      #   <%= link_to_remove_association "Remove", f %>
      #
      # @example With block
      #   <%= link_to_remove_association f do %>
      #     <span class="icon">×</span>
      #   <% end %>
      #
      def link_to_remove_association(name = nil, form = nil, options = {}, &block)
        # Handle block syntax: link_to_remove_association(form) { "Remove" }
        if block_given?
          options = form || {}
          form = name
          name = capture(&block)
        end

        raise ArgumentError, "form is required" unless form

        options = options.dup

        # Build data attributes
        data = options[:data] || {}
        data[:action] = "nested-form#remove"

        options[:data] = data
        options[:href] = "#"

        # Build the hidden _destroy field for persisted records
        hidden_field = if form.object&.persisted?
                         form.hidden_field(:_destroy, value: false)
                       else
                         "".html_safe
                       end

        safe_join([hidden_field, content_tag(:a, name, options)])
      end
    end
  end
end
