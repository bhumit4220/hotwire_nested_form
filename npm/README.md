# hotwire-nested-form-stimulus

A Stimulus controller for dynamic nested forms. Add and remove nested form fields with ease.

## Installation

```bash
npm install hotwire-nested-form-stimulus
# or
yarn add hotwire-nested-form-stimulus
```

## Usage

### Register the Controller

```javascript
import { Application } from "@hotwired/stimulus"
import NestedFormController from "hotwire-nested-form-stimulus"

const application = Application.start()
application.register("nested-form", NestedFormController)
```

### HTML Structure

```html
<div data-controller="nested-form">
  <div id="items">
    <!-- Existing nested fields go here -->
  </div>

  <template data-nested-form-template="NEW_ITEM_RECORD">
    <div class="nested-fields">
      <input name="items[NEW_ITEM_RECORD][name]">
      <a href="#" data-action="nested-form#remove">Remove</a>
    </div>
  </template>
  <a href="#"
     data-action="nested-form#add"
     data-placeholder="NEW_ITEM_RECORD"
     data-insertion="append"
     data-target="#items">
    Add Item
  </a>
</div>
```

### Data Attributes (on add button)

| Attribute | Description | Default |
|-----------|-------------|---------|
| `data-placeholder` | Placeholder string in template to replace with unique ID | `"NEW_RECORD"` |
| `data-insertion` | Where to insert: `before`, `after`, `append`, `prepend` | `before` |
| `data-count` | Number of fields to add per click | `1` |
| `data-target` | CSS selector for insertion container | Parent element |

**Note:** For backward compatibility, `data-template` (inline HTML) is still supported, but `<template>` tags are recommended for deep nesting support.

### Min/Max Limits

```html
<div data-controller="nested-form"
     data-nested-form-min-value="1"
     data-nested-form-max-value="5"
     data-nested-form-limit-behavior-value="disable">
  <!-- fields here -->
</div>
```

| Attribute | Description | Default |
|-----------|-------------|---------|
| `data-nested-form-min-value` | Minimum items required | `0` |
| `data-nested-form-max-value` | Maximum items allowed | unlimited |
| `data-nested-form-limit-behavior-value` | `"disable"`, `"hide"`, or `"error"` | `"disable"` |

### Drag & Drop Sorting

Requires [SortableJS](https://sortablejs.github.io/Sortable/):

```bash
npm install sortablejs
```

```javascript
import Sortable from 'sortablejs'
window.Sortable = Sortable
```

```html
<div data-controller="nested-form"
     data-nested-form-sortable-value="true"
     data-nested-form-sort-handle-value=".drag-handle">

  <div id="items">
    <div class="nested-fields">
      <input type="hidden" name="items[][position]" value="1">
      <span class="drag-handle">☰</span>
      <!-- other fields -->
    </div>
  </div>
</div>
```

| Attribute | Default | Description |
|-----------|---------|-------------|
| `data-nested-form-sortable-value` | `false` | Enable sorting |
| `data-nested-form-position-field-value` | `"position"` | Position field name |
| `data-nested-form-sort-handle-value` | (none) | Drag handle selector |

### Animations

Add smooth CSS transitions when items are added or removed:

```javascript
import "hotwire-nested-form-stimulus/css/animations.css"
```

```html
<div data-controller="nested-form"
     data-nested-form-animation-value="fade"
     data-nested-form-animation-duration-value="300">
  <!-- fields here -->
</div>
```

| Attribute | Default | Description |
|-----------|---------|-------------|
| `data-nested-form-animation-value` | `""` | `"fade"`, `"slide"`, or `""` (none) |
| `data-nested-form-animation-duration-value` | `300` | Duration in milliseconds |

### Deep Nesting

For multi-level nesting, use `<template>` tags and `data-placeholder` attributes. Each nesting level needs its own `data-controller="nested-form"` and a unique placeholder:

```html
<div data-controller="nested-form">
  <div id="tasks">
    <!-- task items here -->
  </div>

  <template data-nested-form-template="NEW_TASK_RECORD">
    <div class="nested-fields">
      <input name="items[tasks][NEW_TASK_RECORD][name]">

      <!-- Nested level 2 -->
      <div data-controller="nested-form">
        <div id="subtasks"></div>
        <template data-nested-form-template="NEW_SUBTASK_RECORD">
          <div class="nested-fields">
            <input name="items[tasks][NEW_TASK_RECORD][subtasks][NEW_SUBTASK_RECORD][name]">
            <a href="#" data-action="nested-form#remove">Remove</a>
          </div>
        </template>
        <a href="#" data-action="nested-form#add"
           data-placeholder="NEW_SUBTASK_RECORD"
           data-insertion="append" data-target="#subtasks">Add Subtask</a>
      </div>
    </div>
  </template>
  <a href="#" data-action="nested-form#add"
     data-placeholder="NEW_TASK_RECORD"
     data-insertion="append" data-target="#tasks">Add Task</a>
</div>
```

The controller replaces only the matching placeholder per button, so nested templates stay intact.

### Accessibility

Accessibility is **enabled by default**. The controller automatically:

- Sets `role="group"` and `aria-label` on the container
- Creates a live region for screen reader announcements
- Manages focus on add/remove/duplicate actions

Disable with:

```html
<div data-controller="nested-form"
     data-nested-form-a11y-value="false">
```

### Duplicate/Clone

Add a duplicate button to clone an existing item with its field values:

```html
<div class="nested-fields">
  <input name="items[][name]" value="Task A">
  <a href="#" data-action="nested-form#duplicate">Duplicate</a>
  <a href="#" data-action="nested-form#remove">Remove</a>
</div>
```

The clone gets a new unique index and any persisted record ID is removed so it saves as a new record.

### Events

| Event | Cancelable | Detail |
|-------|------------|--------|
| `nested-form:before-add` | Yes | `{ wrapper }` |
| `nested-form:after-add` | No | `{ wrapper }` |
| `nested-form:before-remove` | Yes | `{ wrapper }` |
| `nested-form:after-remove` | No | `{ wrapper }` |
| `nested-form:limit-reached` | No | `{ limit, current }` |
| `nested-form:minimum-reached` | No | `{ minimum, current }` |
| `nested-form:before-sort` | Yes | `{ item, oldIndex }` |
| `nested-form:after-sort` | No | `{ item, oldIndex, newIndex }` |
| `nested-form:before-duplicate` | Yes | `{ source }` |
| `nested-form:after-duplicate` | No | `{ source, clone }` |

### Example: Listen for Events

```javascript
document.addEventListener("nested-form:after-add", (event) => {
  console.log("Added:", event.detail.wrapper)
})

document.addEventListener("nested-form:before-remove", (event) => {
  if (!confirm("Are you sure?")) {
    event.preventDefault()
  }
})
```

### With Rails

For Rails users, we recommend using the [hotwire_nested_form](https://rubygems.org/gems/hotwire_nested_form) gem which provides view helpers.

## License

MIT
