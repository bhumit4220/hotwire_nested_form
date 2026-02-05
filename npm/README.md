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

### Events

| Event | Cancelable | Detail |
|-------|------------|--------|
| `nested-form:before-add` | Yes | `{ wrapper }` |
| `nested-form:after-add` | No | `{ wrapper }` |
| `nested-form:before-remove` | Yes | `{ wrapper }` |
| `nested-form:after-remove` | No | `{ wrapper }` |
| `nested-form:limit-reached` | No | `{ limit, current }` |
| `nested-form:minimum-reached` | No | `{ minimum, current }` |

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
