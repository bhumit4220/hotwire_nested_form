import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    wrapperClass: { type: String, default: "nested-fields" }
  }

  add(event) {
    event.preventDefault()

    const template = event.currentTarget.dataset.template
    const insertion = event.currentTarget.dataset.insertion || "before"
    const targetSelector = event.currentTarget.dataset.target
    const count = parseInt(event.currentTarget.dataset.count) || 1

    for (let i = 0; i < count; i++) {
      this.insertFields(template, insertion, targetSelector, event.currentTarget)
    }
  }

  remove(event) {
    event.preventDefault()

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
}
