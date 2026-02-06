import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    wrapperClass: { type: String, default: "nested-fields" },
    min: { type: Number, default: 0 },
    max: { type: Number, default: 999999 },
    limitBehavior: { type: String, default: "disable" },
    sortable: { type: Boolean, default: false },
    positionField: { type: String, default: "position" },
    sortHandle: { type: String, default: "" },
    animation: { type: String, default: "" },
    animationDuration: { type: Number, default: 300 },
    a11y: { type: Boolean, default: true }
  }

  connect() {
    if (this.a11yValue) this.setupAccessibility()
    this.updateButtonStates()
    if (this.sortableValue) this.initializeSortable()
  }

  disconnect() {
    if (this.sortableInstance) this.sortableInstance.destroy()
    if (this.liveRegion) {
      this.liveRegion.remove()
      this.liveRegion = null
    }
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

    const template = this.getTemplate(event.currentTarget)
    const insertion = event.currentTarget.dataset.insertion || "before"
    const targetSelector = event.currentTarget.dataset.target
    const count = parseInt(event.currentTarget.dataset.count) || 1

    for (let i = 0; i < count; i++) {
      if (this.currentCount >= this.maxValue) break
      this.insertFields(template, insertion, targetSelector, event.currentTarget)
    }

    this.updateButtonStates()
    if (this.sortableValue && !this.sortableInstance) this.initializeSortable()
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

    if (this.animationValue) {
      this.animateOut(wrapper, () => this.removeElement(wrapper))
    } else {
      this.removeElement(wrapper)
    }
  }

  removeElement(wrapper) {
    const destroyInput = wrapper.querySelector("input[name*='_destroy']")

    if (destroyInput) {
      destroyInput.value = "true"
      wrapper.style.display = "none"
    } else {
      wrapper.remove()
    }

    this.dispatch("after-remove", { detail: { wrapper } })
    this.updateButtonStates()

    if (this.a11yValue) {
      const addButton = this.element.querySelector('[data-action*="nested-form#add"]')
      if (addButton) addButton.focus()
      this.announce(`Item removed. ${this.currentCount} remaining.`)
    }
  }

  getTemplate(trigger) {
    // Prefer <template> tag (handles deep nesting), fall back to data-template
    const placeholder = trigger.dataset.placeholder
    if (placeholder) {
      const templateEl = this.element.querySelector(
        `template[data-nested-form-template="${placeholder}"]`
      )
      if (templateEl) return templateEl.innerHTML
    }
    return trigger.dataset.template
  }

  insertFields(template, insertion, targetSelector, trigger) {
    const newId = new Date().getTime()
    const placeholder = trigger.dataset.placeholder || "NEW_RECORD"
    const regex = new RegExp(placeholder, "g")
    const content = template.replace(regex, newId)

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

    if (this.animationValue) {
      this.animateIn(wrapper)
    }

    if (this.a11yValue) {
      this.focusFirstInput(wrapper)
      this.announce(`Item ${this.currentCount} added.`)
    }
  }

  // Duplicate

  duplicate(event) {
    event.preventDefault()

    if (this.currentCount >= this.maxValue) {
      this.dispatch("limit-reached", {
        detail: { limit: this.maxValue, current: this.currentCount }
      })
      return
    }

    const wrapper = event.currentTarget.closest(`.${this.wrapperClassValue}`)
    if (!wrapper) return

    const beforeEvent = this.dispatch("before-duplicate", {
      cancelable: true,
      detail: { source: wrapper }
    })

    if (beforeEvent.defaultPrevented) return

    const clone = wrapper.cloneNode(true)
    const newId = new Date().getTime()

    this.prepareClone(clone, newId)

    wrapper.after(clone)

    this.dispatch("after-duplicate", {
      detail: { source: wrapper, clone: clone }
    })

    if (this.animationValue) {
      this.animateIn(clone)
    }

    this.updateButtonStates()
    if (this.sortableValue) this.updatePositions()

    if (this.a11yValue) {
      this.focusFirstInput(clone)
      this.announce("Item duplicated.")
    }
  }

  prepareClone(clone, newId) {
    const idInput = clone.querySelector("input[name*='[id]'][type='hidden']")
    if (idInput) idInput.remove()

    const destroyInput = clone.querySelector("input[name*='_destroy']")
    if (destroyInput) destroyInput.value = "false"

    const elements = clone.querySelectorAll("input, select, textarea, label")
    elements.forEach(el => {
      if (el.name) {
        el.name = el.name.replace(/\[\d+\]/, `[${newId}]`)
      }
      if (el.id) {
        el.id = el.id.replace(/_\d+_/, `_${newId}_`)
      }
      if (el.htmlFor) {
        el.htmlFor = el.htmlFor.replace(/_\d+_/, `_${newId}_`)
      }
    })

    clone.style.display = ""
  }

  // Accessibility

  setupAccessibility() {
    this.element.setAttribute("role", "group")
    if (!this.element.getAttribute("aria-label")) {
      this.element.setAttribute("aria-label", "Nested form fields")
    }

    this.liveRegion = document.createElement("div")
    this.liveRegion.setAttribute("aria-live", "polite")
    this.liveRegion.setAttribute("aria-atomic", "true")
    this.liveRegion.classList.add("nested-form-live-region")
    this.liveRegion.style.cssText = "position:absolute;width:1px;height:1px;overflow:hidden;clip:rect(0,0,0,0)"
    this.element.appendChild(this.liveRegion)
  }

  announce(message) {
    if (!this.liveRegion) return
    this.liveRegion.textContent = ""
    requestAnimationFrame(() => {
      this.liveRegion.textContent = message
    })
  }

  focusFirstInput(wrapper) {
    const focusable = wrapper.querySelector(
      'input:not([type="hidden"]), select, textarea'
    )
    if (focusable) {
      setTimeout(() => focusable.focus(), 50)
    }
  }

  // Animations

  animateIn(element) {
    element.classList.add("nested-form-enter")
    requestAnimationFrame(() => {
      requestAnimationFrame(() => {
        element.classList.add("nested-form-enter-active")
        setTimeout(() => {
          element.classList.remove("nested-form-enter", "nested-form-enter-active")
        }, this.animationDurationValue)
      })
    })
  }

  animateOut(element, callback) {
    element.classList.add("nested-form-exit-active")

    const done = () => {
      element.classList.remove("nested-form-exit-active")
      callback()
    }

    element.addEventListener("transitionend", done, { once: true })
    // Fallback if transitionend doesn't fire
    setTimeout(done, this.animationDurationValue + 50)
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
