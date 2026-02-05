# frozen_string_literal: true

module HotwireNestedForm
  class Engine < ::Rails::Engine
    isolate_namespace HotwireNestedForm

    # Auto-include helpers in all views
    initializer 'hotwire_nested_form.helpers' do
      ActiveSupport.on_load(:action_view) do
        include HotwireNestedForm::Helpers
      end
    end

    # Support for asset pipeline (fallback)
    initializer 'hotwire_nested_form.assets' do |app|
      app.config.assets.paths << Engine.root.join('app/assets/javascripts') if app.config.respond_to?(:assets)
    end
  end
end
