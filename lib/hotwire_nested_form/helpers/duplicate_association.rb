# frozen_string_literal: true

module HotwireNestedForm
  module Helpers
    module DuplicateAssociation
      # Generates a link to duplicate a nested form item
      #
      # @param name [String] Link text (or use block)
      # @param form [FormBuilder] Nested form object
      # @param options [Hash] HTML attributes
      # @yield Block for custom link content
      # @return [String] HTML link element
      #
      # @example Basic usage
      #   <%= link_to_duplicate_association "Duplicate", f %>
      #
      # @example With block
      #   <%= link_to_duplicate_association f do %>
      #     <span>Copy</span>
      #   <% end %>
      #
      def link_to_duplicate_association(name = nil, form = nil, options = {}, &)
        if block_given?
          options = form || {}
          form = name
          name = capture(&)
        end

        raise ArgumentError, 'form is required' unless form

        options = options.dup

        data = options[:data] || {}
        data[:action] = 'nested-form#duplicate'

        options[:data] = data
        options[:href] = '#'

        content_tag(:a, name, options)
      end
    end
  end
end
