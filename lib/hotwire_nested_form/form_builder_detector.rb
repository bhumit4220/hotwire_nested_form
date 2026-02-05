# frozen_string_literal: true

module HotwireNestedForm
  module FormBuilderDetector
    module_function

    def simple_form?(form_builder)
      return false unless form_builder

      builder_class = form_builder.class.name.to_s
      builder_class.include?('SimpleForm')
    end

    def formtastic?(form_builder)
      return false unless form_builder

      builder_class = form_builder.class.name.to_s
      builder_class.include?('Formtastic')
    end

    def simple_form_available?
      defined?(::SimpleForm) ? true : false
    end

    def formtastic_available?
      defined?(::Formtastic) ? true : false
    end
  end
end
