# HotwireNestedForm

[![Gem Version](https://badge.fury.io/rb/hotwire_nested_form.svg)](https://badge.fury.io/rb/hotwire_nested_form)
[![CI](https://github.com/bhumit4220/hotwire_nested_form/actions/workflows/test.yml/badge.svg)](https://github.com/bhumit4220/hotwire_nested_form/actions)

A modern, Stimulus-based gem for dynamic nested forms in Rails. Drop-in replacement for Cocoon with zero jQuery dependency and full Turbo compatibility.

## Why HotwireNestedForm?

| Feature | Cocoon | HotwireNestedForm |
|---------|--------|-------------------|
| jQuery required | Yes | No |
| Turbo compatible | No | Yes |
| `preventDefault()` works | No | Yes |
| Maintained | No (since 2020) | Yes |
| Rails 7+ support | Partial | Full |

## Installation

Add to your Gemfile:

```ruby
gem "hotwire_nested_form"
```

Run the installer:

```bash
bundle install
rails generate hotwire_nested_form:install
```

## Quick Start

### 1. Model Setup

```ruby
# app/models/project.rb
class Project < ApplicationRecord
  has_many :tasks, dependent: :destroy
  accepts_nested_attributes_for :tasks, allow_destroy: true, reject_if: :all_blank
end
```

### 2. Controller Setup

```ruby
# app/controllers/projects_controller.rb
def project_params
  params.require(:project).permit(:name, tasks_attributes: [:id, :name, :_destroy])
end
```

### 3. Form Setup

```erb
<%# app/views/projects/_form.html.erb %>
<%= form_with model: @project do |f| %>
  <%= f.text_field :name %>

  <div data-controller="nested-form">
    <div id="tasks">
      <%= f.fields_for :tasks do |task_form| %>
        <%= render "task_fields", f: task_form %>
      <% end %>
    </div>

    <%= link_to_add_association "Add Task", f, :tasks %>
  </div>

  <%= f.submit %>
<% end %>
```

### 4. Fields Partial

```erb
<%# app/views/projects/_task_fields.html.erb %>
<div class="nested-fields">
  <%= f.text_field :name, placeholder: "Task name" %>
  <%= link_to_remove_association "Remove", f %>
</div>
```

That's it! Click "Add Task" to add fields, "Remove" to remove them.

## SimpleForm Support

Works automatically with SimpleForm! No configuration needed.

```erb
<%= simple_form_for @project do |f| %>
  <%= f.input :name %>

  <div data-controller="nested-form">
    <%= f.simple_fields_for :tasks do |task_form| %>
      <%= render "task_fields", f: task_form %>
    <% end %>

    <%= link_to_add_association "Add Task", f, :tasks %>
  </div>

  <%= f.button :submit %>
<% end %>
```

## Formtastic Support

Works automatically with Formtastic! No configuration needed.

```erb
<%= semantic_form_for @project do |f| %>
  <%= f.input :name %>

  <div data-controller="nested-form">
    <%= f.semantic_fields_for :tasks do |task_form| %>
      <%= render "task_fields", f: task_form %>
    <% end %>

    <%= link_to_add_association "Add Task", f, :tasks %>
  </div>

  <%= f.actions %>
<% end %>
```

## Min/Max Limits

Control the number of nested items with data attributes:

```erb
<div data-controller="nested-form"
     data-nested-form-min-value="1"
     data-nested-form-max-value="5"
     data-nested-form-limit-behavior-value="disable">

  <%= f.fields_for :tasks do |tf| %>
    <%= render "task_fields", f: tf %>
  <% end %>

  <%= link_to_add_association "Add Task", f, :tasks %>
</div>
```

### Limit Options

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `data-nested-form-min-value` | Integer | `0` | Minimum items required |
| `data-nested-form-max-value` | Integer | unlimited | Maximum items allowed |
| `data-nested-form-limit-behavior-value` | String | `"disable"` | `"disable"`, `"hide"`, or `"error"` |

### Limit Behaviors

| Behavior | At Max Limit | At Min Limit |
|----------|--------------|--------------|
| `disable` | Add button disabled | Remove buttons disabled |
| `hide` | Add button hidden | Remove buttons hidden |
| `error` | Event fires, button enabled | Event fires, button enabled |

### Dynamic Limits

Change limits at runtime via JavaScript:

```javascript
const form = document.querySelector('[data-controller="nested-form"]')
form.dataset.nestedFormMaxValue = 10  // Change max
form.dataset.nestedFormMinValue = 2   // Change min
```

### Limit Events

```javascript
document.addEventListener("nested-form:limit-reached", (event) => {
  alert(`Maximum ${event.detail.limit} items allowed`)
})

document.addEventListener("nested-form:minimum-reached", (event) => {
  alert(`Must keep at least ${event.detail.minimum} items`)
})
```

## Drag & Drop Sorting

Enable drag & drop reordering with position persistence:

### 1. Install SortableJS

```bash
# Rails with importmap
bin/importmap pin sortablejs

# OR npm/yarn
npm install sortablejs
```

### 2. Add Position to Your Model

```bash
rails generate migration AddPositionToTasks position:integer
rails db:migrate
```

```ruby
# app/models/task.rb
class Task < ApplicationRecord
  belongs_to :project
  default_scope { order(:position) }
end
```

### 3. Update Your Partial

```erb
<%# app/views/projects/_task_fields.html.erb %>
<div class="nested-fields">
  <%= f.hidden_field :position %>
  <span class="drag-handle">☰</span>
  <%= f.text_field :name %>
  <%= link_to_remove_association "Remove", f %>
</div>
```

### 4. Enable Sorting

```erb
<div data-controller="nested-form"
     data-nested-form-sortable-value="true"
     data-nested-form-sort-handle-value=".drag-handle">
  <!-- nested fields -->
</div>
```

### 5. Permit Position in Controller

```ruby
params.require(:project).permit(:name,
  tasks_attributes: [:id, :name, :position, :_destroy])
```

### Sorting Options

| Attribute | Default | Description |
|-----------|---------|-------------|
| `data-nested-form-sortable-value` | `false` | Enable drag & drop |
| `data-nested-form-position-field-value` | `"position"` | Position field name |
| `data-nested-form-sort-handle-value` | (none) | Drag handle selector |

### Sorting Events

| Event | Detail | Description |
|-------|--------|-------------|
| `nested-form:before-sort` | `{ item, oldIndex }` | Before drag (cancelable) |
| `nested-form:after-sort` | `{ item, oldIndex, newIndex }` | After drop |

### Example CSS

```css
.drag-handle {
  cursor: grab;
  user-select: none;
}

.nested-form-dragging {
  opacity: 0.8;
  background: #e3f2fd;
}

.nested-form-drag-ghost {
  opacity: 0.4;
  border: 2px dashed #2196F3;
}
```

## Animations

Add smooth CSS transitions when items are added or removed:

```erb
<div data-controller="nested-form"
     data-nested-form-animation-value="fade"
     data-nested-form-animation-duration-value="300">
  <!-- nested fields -->
</div>
```

### Include the Animation Stylesheet

**Rails (generator):**
```bash
rails g hotwire_nested_form:install --animations
```

**Rails (manual):** Add to your stylesheet:
```css
@import "hotwire_nested_form/animations";
```

**NPM:**
```javascript
import "hotwire-nested-form-stimulus/css/animations.css"
```

### Animation Options

| Attribute | Default | Description |
|-----------|---------|-------------|
| `data-nested-form-animation-value` | `""` | `"fade"`, `"slide"`, or `""` (none) |
| `data-nested-form-animation-duration-value` | `300` | Duration in milliseconds |

### CSS Classes

| Class | When Applied |
|-------|-------------|
| `nested-form-enter` | Immediately on add |
| `nested-form-enter-active` | Next frame after add (triggers transition) |
| `nested-form-exit-active` | On remove (triggers transition, then element is hidden/removed) |

You can customize the animations by overriding these classes in your stylesheet.

## Deep Nesting (Multi-Level)

Nest forms inside forms (e.g. Project -> Tasks -> Subtasks):

### 1. Model Setup

```ruby
class Project < ApplicationRecord
  has_many :tasks, dependent: :destroy
  accepts_nested_attributes_for :tasks, allow_destroy: true
end

class Task < ApplicationRecord
  belongs_to :project
  has_many :subtasks, dependent: :destroy
  accepts_nested_attributes_for :subtasks, allow_destroy: true
end
```

### 2. Form Setup

```erb
<%# _form.html.erb %>
<%= form_with model: @project do |f| %>
  <div data-controller="nested-form">
    <div id="tasks">
      <%= f.fields_for :tasks do |tf| %>
        <%= render "task_fields", f: tf %>
      <% end %>
    </div>
    <%= link_to_add_association "Add Task", f, :tasks,
          insertion: :append, target: "#tasks" %>
  </div>
  <%= f.submit %>
<% end %>

<%# _task_fields.html.erb %>
<div class="nested-fields">
  <%= f.text_field :name %>
  <%= link_to_remove_association "Remove Task", f %>

  <div data-controller="nested-form">
    <div id="subtasks">
      <%= f.fields_for :subtasks do |sf| %>
        <%= render "subtask_fields", f: sf %>
      <% end %>
    </div>
    <%= link_to_add_association "Add Subtask", f, :subtasks,
          insertion: :append, target: "#subtasks" %>
  </div>
</div>

<%# _subtask_fields.html.erb %>
<div class="nested-fields">
  <%= f.text_field :name %>
  <%= link_to_remove_association "Remove", f %>
</div>
```

### 3. Controller Params

```ruby
def project_params
  params.require(:project).permit(:name,
    tasks_attributes: [:id, :name, :_destroy,
      subtasks_attributes: [:id, :name, :_destroy]])
end
```

Each nesting level automatically gets a unique placeholder (`NEW_TASK_RECORD`, `NEW_SUBTASK_RECORD`) so adding items at one level doesn't affect templates at other levels. Each `data-controller="nested-form"` operates independently.

## NPM Package (JavaScript-only)

For non-Rails projects using Stimulus, install via npm:

```bash
npm install hotwire-nested-form-stimulus
```

Register the controller:

```javascript
import { Application } from "@hotwired/stimulus"
import NestedFormController from "hotwire-nested-form-stimulus"

const application = Application.start()
application.register("nested-form", NestedFormController)
```

See [NPM package documentation](npm/README.md) for full details.

## API Reference

### link_to_add_association

```ruby
link_to_add_association(name, form, association, options = {}, &block)
```

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `:partial` | String | `"#{assoc}_fields"` | Custom partial path |
| `:count` | Integer | `1` | Fields to add per click |
| `:insertion` | Symbol | `:before` | `:before`, `:after`, `:append`, `:prepend` |
| `:target` | String | `nil` | CSS selector for insertion target |
| `:wrap_object` | Proc | `nil` | Wrap new object (for decorators) |
| `:render_options` | Hash | `{}` | Options passed to `render` |

**Examples:**

```erb
<%# Basic usage %>
<%= link_to_add_association "Add Task", f, :tasks %>

<%# With custom partial %>
<%= link_to_add_association "Add Task", f, :tasks,
      partial: "projects/custom_task_fields" %>

<%# With block for custom content %>
<%= link_to_add_association f, :tasks do %>
  <span class="icon">+</span> Add Task
<% end %>

<%# With HTML classes %>
<%= link_to_add_association "Add Task", f, :tasks,
      class: "btn btn-primary" %>

<%# Add multiple at once %>
<%= link_to_add_association "Add 3 Tasks", f, :tasks, count: 3 %>
```

### link_to_remove_association

```ruby
link_to_remove_association(name, form, options = {}, &block)
```

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `:wrapper_class` | String | `"nested-fields"` | Class of wrapper to remove |

**Examples:**

```erb
<%# Basic usage %>
<%= link_to_remove_association "Remove", f %>

<%# With custom wrapper class %>
<%= link_to_remove_association "Remove", f,
      wrapper_class: "task-item" %>

<%# With block %>
<%= link_to_remove_association f do %>
  <span class="icon">&times;</span> Remove
<% end %>
```

## JavaScript Events

| Event | Cancelable | Detail | When |
|-------|------------|--------|------|
| `nested-form:before-add` | Yes | `{ wrapper }` | Before adding fields |
| `nested-form:after-add` | No | `{ wrapper }` | After fields added |
| `nested-form:before-remove` | Yes | `{ wrapper }` | Before removing fields |
| `nested-form:after-remove` | No | `{ wrapper }` | After fields removed |
| `nested-form:limit-reached` | No | `{ limit, current }` | When max limit reached |
| `nested-form:minimum-reached` | No | `{ minimum, current }` | When min limit reached |
| `nested-form:before-sort` | Yes | `{ item, oldIndex }` | Before drag starts |
| `nested-form:after-sort` | No | `{ item, oldIndex, newIndex }` | After drop completes |

**Usage Examples:**

```javascript
// Prevent adding if limit reached
document.addEventListener("nested-form:before-add", (event) => {
  const taskCount = document.querySelectorAll(".nested-fields").length
  if (taskCount >= 10) {
    event.preventDefault()
    alert("Maximum 10 tasks allowed")
  }
})

// Initialize plugins on new fields
document.addEventListener("nested-form:after-add", (event) => {
  const wrapper = event.detail.wrapper
  // Initialize datepicker, select2, etc.
})

// Confirm before removing
document.addEventListener("nested-form:before-remove", (event) => {
  if (!confirm("Are you sure?")) {
    event.preventDefault()
  }
})

// Update totals after removal
document.addEventListener("nested-form:after-remove", (event) => {
  updateTaskCount()
})
```

## Migrating from Cocoon

1. Replace gem in Gemfile:
   ```ruby
   # Remove: gem "cocoon"
   gem "hotwire_nested_form"
   ```

2. Run installer:
   ```bash
   bundle install
   rails generate hotwire_nested_form:install
   ```

3. Add `data-controller="nested-form"` to your form wrapper:
   ```erb
   <div data-controller="nested-form">
     <!-- your fields_for and links here -->
   </div>
   ```

4. Update event listeners (optional):
   ```javascript
   // Before: cocoon:before-insert
   // After: nested-form:before-add

   // Before: cocoon:after-insert
   // After: nested-form:after-add

   // Before: cocoon:before-remove
   // After: nested-form:before-remove

   // Before: cocoon:after-remove
   // After: nested-form:after-remove
   ```

5. Remove jQuery if no longer needed.

## Requirements

- Ruby 3.1+
- Rails 7.0+ (including Rails 8)
- Stimulus (included in Rails 7+ by default)

## Development

After checking out the repo, run:

```bash
bundle install
bundle exec rspec
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bhumit4220/hotwire_nested_form.

## License

MIT License. See [LICENSE](LICENSE) for details.
