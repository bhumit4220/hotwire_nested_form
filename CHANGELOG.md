# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.4.0] - 2026-02-06

### Added
- Add/remove animations with CSS transitions
  - `data-nested-form-animation-value` - animation type: `"fade"`, `"slide"`, or `""` (none)
  - `data-nested-form-animation-duration-value` - duration in ms (default: 300)
  - CSS classes: `nested-form-enter`, `nested-form-enter-active`, `nested-form-exit-active`
  - Optional animation stylesheet: `hotwire_nested_form/animations.css`
  - Install with: `rails g hotwire_nested_form:install --animations`
  - NPM users: `import "hotwire-nested-form-stimulus/css/animations.css"`
- Deep nesting (multi-level nested forms)
  - Association-specific placeholders (`NEW_TASK_RECORD`, `NEW_SUBTASK_RECORD`) prevent collisions
  - Each `link_to_add_association` automatically generates unique placeholders per association
  - `<template>` tags for template storage (replaces `data-template` attribute for reliable deep nesting)
  - Full backward compatibility - single-level forms work unchanged

### Changed
- Template HTML now stored in `<template>` tags instead of `data-template` attributes
- `link_to_add_association` outputs `<template>` + `<a>` tag pair
- Controller `remove()` refactored into `remove()` + `removeElement()` for animation support
- Added `getTemplate()` method for flexible template lookup

## [1.3.0] - 2026-02-06

### Added
- Drag & drop sorting for nested items (requires SortableJS)
  - `data-nested-form-sortable-value` - enable sorting
  - `data-nested-form-position-field-value` - custom position field name
  - `data-nested-form-sort-handle-value` - CSS selector for drag handle
- New events: `nested-form:before-sort` and `nested-form:after-sort`
- CSS classes for drag styling: `nested-form-dragging`, `nested-form-drag-ghost`

### Changed
- Controller now cleans up Sortable instance on disconnect

## [1.2.0] - 2026-02-05

### Added
- Dynamic min/max limits via data attributes
  - `data-nested-form-min-value` - minimum items required
  - `data-nested-form-max-value` - maximum items allowed
  - `data-nested-form-limit-behavior-value` - behavior at limits: "disable", "hide", or "error"
- New events: `nested-form:limit-reached` and `nested-form:minimum-reached`
- Formtastic form builder auto-detection and compatibility
- `formtastic?` and `formtastic_available?` methods in FormBuilderDetector

### Changed
- Stimulus controller now updates button states automatically
- Buttons disable/hide based on current count vs limits

## [1.1.0] - 2026-02-05

### Added
- SimpleForm auto-detection and compatibility
- NPM package `hotwire-nested-form-stimulus` for JavaScript-only users
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
