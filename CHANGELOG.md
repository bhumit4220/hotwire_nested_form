# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.1.0] - 2026-02-05

### Added
- SimpleForm auto-detection and compatibility
- NPM package `@hotwire-nested-form/stimulus` for JavaScript-only users
- `FormBuilderDetector` module for form builder type detection

### Changed
- Improved documentation for SimpleForm usage

## [1.0.0] - 2026-02-05

### Added
- Initial release
- `link_to_add_association` helper for adding nested form fields
- `link_to_remove_association` helper for removing nested form fields
- Stimulus controller for add/remove functionality
- Event system with cancelable events:
  - `nested-form:before-add`
  - `nested-form:after-add`
  - `nested-form:before-remove`
  - `nested-form:after-remove`
- Support for Rails 7.0, 7.1, and 8.0
- Support for Ruby 3.1, 3.2, and 3.3
- Installation generator (`rails g hotwire_nested_form:install`)
- Full documentation and migration guide from Cocoon
- Comprehensive test suite (helper specs + system specs)
