# frozen_string_literal: true

module HotwireNestedForm
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      desc 'Install hotwire_nested_form'

      class_option :animations, type: :boolean, default: false,
                                desc: 'Copy animation stylesheet'

      def copy_stimulus_controller
        copy_file 'nested_form_controller.js',
                  'app/javascript/controllers/nested_form_controller.js'
      end

      def copy_animation_stylesheet
        return unless options[:animations]

        copy_file 'animations.css',
                  'app/assets/stylesheets/hotwire_nested_form/animations.css'
      end

      def show_post_install_message
        say ''
        say '=' * 60
        say 'hotwire_nested_form installed successfully!', :green
        say '=' * 60
        say ''
        say 'Next steps:', :yellow
        say ''
        say '1. Add accepts_nested_attributes_for to your model:'
        say ''
        say '   class Project < ApplicationRecord'
        say '     has_many :tasks, dependent: :destroy'
        say '     accepts_nested_attributes_for :tasks, allow_destroy: true'
        say '   end'
        say ''
        say '2. Wrap your form in data-controller="nested-form":'
        say ''
        say '   <%= form_with model: @project do |f| %>'
        say '     <div data-controller="nested-form">'
        say '       <div id="tasks">'
        say '         <%= f.fields_for :tasks do |tf| %>'
        say "           <%= render 'task_fields', f: tf %>"
        say '         <% end %>'
        say '       </div>'
        say "       <%= link_to_add_association 'Add Task', f, :tasks %>"
        say '     </div>'
        say '   <% end %>'
        say ''
        say '3. Create a partial for your nested fields:'
        say ''
        say '   <%# _task_fields.html.erb %>'
        say '   <div class="nested-fields">'
        say '     <%= f.text_field :name %>'
        say "     <%= link_to_remove_association 'Remove', f %>"
        say '   </div>'
        say ''
        say '4. Permit nested attributes in your controller:'
        say ''
        say '   def project_params'
        say '     params.require(:project).permit(:name,'
        say '       tasks_attributes: [:id, :name, :_destroy])'
        say '   end'
        say ''
        say '=' * 60
        say ''
      end
    end
  end
end
