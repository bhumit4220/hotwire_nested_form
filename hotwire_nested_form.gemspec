# frozen_string_literal: true

require_relative 'lib/hotwire_nested_form/version'

Gem::Specification.new do |spec|
  spec.name          = 'hotwire_nested_form'
  spec.version       = HotwireNestedForm::VERSION
  spec.authors       = ['BhumitBhadani']
  spec.email         = ['bhumit2520@gmail.com']

  spec.summary       = 'Dynamic nested forms for Rails with Stimulus'
  spec.description   = 'A modern, Stimulus-based replacement for Cocoon. ' \
                       'Dynamically add and remove nested form fields with ' \
                       'full Turbo compatibility and zero jQuery dependency.'
  spec.homepage      = 'https://github.com/bhumit4220/hotwire_nested_form'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata = {
    'homepage_uri' => spec.homepage,
    'source_code_uri' => 'https://github.com/bhumit4220/hotwire_nested_form',
    'changelog_uri' => 'https://github.com/bhumit4220/hotwire_nested_form/blob/main/CHANGELOG.md',
    'bug_tracker_uri' => 'https://github.com/bhumit4220/hotwire_nested_form/issues',
    'documentation_uri' => 'https://github.com/bhumit4220/hotwire_nested_form#readme',
    'rubygems_mfa_required' => 'true'
  }

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) ||
        f.match(%r{\A(?:(?:spec|test|features)/|\.(?:git|github|rspec))})
    end
  end

  spec.require_paths = ['lib']

  # Runtime dependencies - keep minimal!
  spec.add_dependency 'rails', '>= 7.0'
end
