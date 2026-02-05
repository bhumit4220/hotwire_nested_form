import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    wrapperClass: { type: String, default: "nested-fields" },
    min: { type: Number, default: 0 },
    max: { type: Number, default: 999999 },
    limitBehavior: { type: String, default: "disable" },
    sortable: { type: Boolean, default: false },
    positionField: { type: String, default: "position" },
    sortHandle: { type: String, default: "" }
  }

  connect() {
    this.updateButtonStates()
    if (this.sortableValue) this.initializeSortable()
  }

  disconnect() {
    if (this.sortableInstance) this.sortableInstance.destroy()
  }

  get currentCount() {
    return this.element.querySelectorAll(`.${this.wrapperClassValue}:not([style*="display: none"])`).length
  }

  get addButtons() {
    return this.element.querySelectorAll('[data-action*="nested-form#add"]')
  }

  get removeButtons() {
    return this.element.querySelectorAll('[data-action*="nested-form#remove"]')
  }

  add(event) {
    event.preventDefault()

    if (this.currentCount >= this.maxValue) {
      this.dispatch("limit-reached", {
        detail: { limit: this.maxValue, current: this.currentCount }
      })
      return
    }

    const template = event.currentTarget.dataset.template
    const insertion = event.currentTarget.dataset.insertion || "before"
    const targetSelector = event.currentTarget.dataset.target
    const count = parseInt(event.currentTarget.dataset.count) || 1

    for (let i = 0; i < count; i++) {
      if (this.currentCount >= this.maxValue) break
      this.insertFields(template, insertion, targetSelector, event.currentTarget)
    }

    this.updateButtonStates()
  }

  remove(event) {
    event.preventDefault()

    if (this.currentCount <= this.minValue) {
      this.dispatch("minimum-reached", {
        detail: { minimum: this.minValue, current: this.currentCount }
      })
      return
    }

    const wrapper = event.currentTarget.closest(`.${this.wrapperClassValue}`)
    if (!wrapper) return

    const beforeEvent = this.dispatch("before-remove", {
      cancelable: true,
      detail: { wrapper }
    })

    if (beforeEvent.defaultPrevented) return

    const destroyInput = wrapper.querySelector("input[name*='_destroy']")

    if (destroyInput) {
      destroyInput.value = "true"
      wrapper.style.display = "none"
    } else {
      wrapper.remove()
    }

    this.dispatch("after-remove", { detail: { wrapper } })
    this.updateButtonStates()
  }

  insertFields(template, insertion, targetSelector, trigger) {
    const newId = new Date().getTime()
    const content = template.replace(/NEW_RECORD/g, newId)

    const fragment = document.createRange().createContextualFragment(content)
    const wrapper = fragment.firstElementChild

    const beforeEvent = this.dispatch("before-add", {
      cancelable: true,
      detail: { wrapper }
    })

    if (beforeEvent.defaultPrevented) return

    const container = targetSelector
      ? document.querySelector(targetSelector)
      : trigger.parentElement

    switch (insertion) {
      case "after":
        trigger.after(fragment)
        break
      case "append":
        container.append(fragment)
        break
      case "prepend":
        container.prepend(fragment)
        break
      default:
        trigger.before(fragment)
    }

    this.dispatch("after-add", { detail: { wrapper } })
  }

  updateButtonStates() {
    const atMax = this.currentCount >= this.maxValue
    const atMin = this.currentCount <= this.minValue

    this.addButtons.forEach(button => {
      this.applyLimitState(button, atMax)
    })

    this.removeButtons.forEach(button => {
      const wrapper = button.closest(`.${this.wrapperClassValue}`)
      if (wrapper && wrapper.style.display !== "none") {
        this.applyLimitState(button, atMin)
      }
    })
  }

  applyLimitState(button, isAtLimit) {
    switch (this.limitBehaviorValue) {
      case "hide":
        button.style.display = isAtLimit ? "none" : ""
        button.disabled = false
        break
      case "error":
        button.disabled = false
        button.style.display = ""
        break
      default: // "disable"
        button.disabled = isAtLimit
        button.style.display = ""
    }
  }

  // Drag & Drop Sorting

  initializeSortable() {
    if (typeof Sortable === 'undefined') {
      console.warn('hotwire_nested_form: SortableJS not found. Install it for drag & drop sorting: https://sortablejs.github.io/Sortable/')
      return
    }

    const container = this.findSortableContainer()
    if (!container) return

    this.sortableInstance = Sortable.create(container, {
      animation: 150,
      handle: this.sortHandleValue || null,
      draggable: `.${this.wrapperClassValue}`,
      ghostClass: 'nested-form-drag-ghost',
      chosenClass: 'nested-form-dragging',
      onStart: (evt) => this.onSortStart(evt),
      onEnd: (evt) => this.onSortEnd(evt)
    })
  }

  findSortableContainer() {
    // Look for common container patterns
    const selectors = ['#tasks', '#items', '[data-nested-form-target="container"]']
    for (const selector of selectors) {
      const container = this.element.querySelector(selector)
      if (container) return container
    }
    // Fallback: find first element containing nested-fields
    const firstField = this.element.querySelector(`.${this.wrapperClassValue}`)
    return firstField ? firstField.parentElement : this.element
  }

  onSortStart(evt) {
    const beforeEvent = this.dispatch("before-sort", {
      cancelable: true,
      detail: { item: evt.item, oldIndex: evt.oldIndex }
    })

    if (beforeEvent.defaultPrevented) {
      this.sortableInstance.option("disabled", true)
      setTimeout(() => this.sortableInstance.option("disabled", false), 0)
    }
  }

  onSortEnd(evt) {
    this.updatePositions()

    this.dispatch("after-sort", {
      detail: {
        item: evt.item,
        oldIndex: evt.oldIndex,
        newIndex: evt.newIndex
      }
    })

    this.updateButtonStates()
  }

  updatePositions() {
    const items = this.element.querySelectorAll(
      `.${this.wrapperClassValue}:not([style*="display: none"])`
    )

    items.forEach((item, index) => {
      const positionInput = item.querySelector(
        `input[name*="[${this.positionFieldValue}]"]`
      )
      if (positionInput) {
        positionInput.value = index + 1
      }
    })
  }
}
