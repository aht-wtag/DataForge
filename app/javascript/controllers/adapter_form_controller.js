import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dilocFields"]

  connect() {
    this.toggleFields()
  }

  toggleFields() {
    const select = this.element.querySelector('[data-adapter-type-select="true"]')
    if (!select) return

    const isDiloc = select.value === 'diloc'

    this.dilocFieldsTargets.forEach((el) => {
      el.style.display = isDiloc ? 'block' : 'none'

      el.querySelectorAll('input, select').forEach((input) => {
        if (isDiloc) {
          if (input.dataset.required === 'true') {
            input.setAttribute('required', 'required')
          }
        } else {
          input.removeAttribute('required')
        }
      })
    })
  }
}
