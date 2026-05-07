import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["radio", "cardForm", "cardFormEl", "reimbursementFormEl", "submitBtn"]

  select() {
    const selected = this.radioTargets.find(r => r.checked)?.value

    if (selected === "card") {
      this.cardFormTarget.classList.remove("hidden")
      this.submitBtnTarget.textContent = "Start spending"
      this.submitBtnTarget.disabled = false
    } else if (selected === "reimbursement") {
      this.cardFormTarget.classList.add("hidden")
      this.submitBtnTarget.textContent = "Open reimbursement report"
      this.submitBtnTarget.disabled = false
    } else {
      this.cardFormTarget.classList.add("hidden")
      this.submitBtnTarget.textContent = "Select an option to continue"
      this.submitBtnTarget.disabled = true
    }
  }

  submit() {
    const selected = this.radioTargets.find(r => r.checked)?.value

    if (selected === "card") {
      this.cardFormElTarget.requestSubmit()
    } else if (selected === "reimbursement") {
      this.reimbursementFormElTarget.requestSubmit()
    }
  }
}
