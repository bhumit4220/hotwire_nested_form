# @hotwire-nested-form/stimulus

A Stimulus controller for dynamic nested forms. Add and remove nested form fields with ease.

## Installation

```bash
npm install @hotwire-nested-form/stimulus
# or
yarn add @hotwire-nested-form/stimulus
```

## Usage

### Register the Controller

```javascript
import { Application } from "@hotwired/stimulus"
import NestedFormController from "@hotwire-nested-form/stimulus"

const application = Application.start()
application.register("nested-form", NestedFormController)
```

### HTML Structure

```html
<div data-controller="nested-form">
  <div id="items">
    <!-- Existing nested fields go here -->
  </div>

  <a href="#"
     data-action="nested-form#add"
     data-template="<div class='nested-fields'><input name='items[][name]'><a href='#' data-action='nested-form#remove'>Remove</a></div>">
    Add Item
  </a>
</div>
```

### Data Attributes

| Attribute | Description | Default |
|-----------|-------------|---------|
| `data-template` | HTML template for new fields (use `NEW_RECORD` as placeholder) | Required |
| `data-insertion` | Where to insert: `before`, `after`, `append`, `prepend` | `before` |
| `data-count` | Number of fields to add per click | `1` |
| `data-target` | CSS selector for insertion container | Parent element |

### Events

| Event | Cancelable | Detail |
|-------|------------|--------|
| `nested-form:before-add` | Yes | `{ wrapper }` |
| `nested-form:after-add` | No | `{ wrapper }` |
| `nested-form:before-remove` | Yes | `{ wrapper }` |
| `nested-form:after-remove` | No | `{ wrapper }` |

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
