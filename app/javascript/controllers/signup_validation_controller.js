import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["email", "emailFeedback", "password", "passwordConfirmation", "matchFeedback", "submit"]

  connect() {
    this.toggleSubmit()
  }

  checkEmail() {
    const email = this.emailTarget.value.trim()
    if (!email || !email.match(/^[^@\s]+@[^@\s]+\.[^@\s]+$/)) {
      this.setEmailFeedback("", "")
      this.toggleSubmit()
      return
    }

    clearTimeout(this.emailTimeout)
    this.emailTimeout = setTimeout(() => {
      fetch(`/check_email?email=${encodeURIComponent(email)}`, {
        headers: { "Accept": "application/json" }
      })
        .then(response => response.json())
        .then(data => {
          if (data.taken) {
            this.setEmailFeedback("This email is already registered.", "text-red-600")
          } else {
            this.setEmailFeedback("Email is available.", "text-green-600")
          }
          this.toggleSubmit()
        })
        .catch(() => {
          this.setEmailFeedback("", "")
          this.toggleSubmit()
        })
    }, 400)
  }

  checkPasswordMatch() {
    const password = this.passwordTarget.value
    const confirmation = this.passwordConfirmationTarget.value

    if (!confirmation) {
      this.matchFeedbackTarget.textContent = ""
      this.matchFeedbackTarget.className = "text-xs mt-1"
      this.passwordConfirmationTarget.classList.remove("border-red-500", "border-green-500")
      this.toggleSubmit()
      return
    }

    if (password === confirmation) {
      this.matchFeedbackTarget.textContent = "Passwords match."
      this.matchFeedbackTarget.className = "text-xs mt-1 text-green-600"
      this.passwordConfirmationTarget.classList.remove("border-red-500")
      this.passwordConfirmationTarget.classList.add("border-green-500")
    } else {
      this.matchFeedbackTarget.textContent = "Passwords do not match."
      this.matchFeedbackTarget.className = "text-xs mt-1 text-red-600"
      this.passwordConfirmationTarget.classList.remove("border-green-500")
      this.passwordConfirmationTarget.classList.add("border-red-500")
    }
    this.toggleSubmit()
  }

  setEmailFeedback(message, colorClass) {
    this.emailFeedbackTarget.textContent = message
    this.emailFeedbackTarget.className = `text-xs mt-1 ${colorClass}`
  }

  toggleSubmit() {
    const email = this.emailTarget.value.trim()
    const password = this.passwordTarget.value
    const confirmation = this.passwordConfirmationTarget.value
    const passwordsMatch = password === confirmation
    const emailTaken = this.emailFeedbackTarget.classList.contains("text-red-600")

    const disabled = !email || !password || !confirmation || !passwordsMatch || emailTaken

    this.submitTarget.disabled = disabled
    if (disabled) {
      this.submitTarget.classList.add("opacity-50", "cursor-not-allowed")
    } else {
      this.submitTarget.classList.remove("opacity-50", "cursor-not-allowed")
    }
  }
}
