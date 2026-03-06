import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["subtotal", "taxDisplay", "tipDisplay", "grandTotal"]

  connect() {
    this.updateTotals()
    this.element.querySelectorAll("input[type='number']").forEach(input => {
      input.addEventListener("input", () => this.updateTotals())
      input.addEventListener("change", () => this.updateTotals())
    })
  }

  updateTotals() {
    let subtotal = 0
    this.element.querySelectorAll("input[name*='[amount_rupees]']").forEach(input => {
      if (!input.name.includes("expense_item_shares")) {
        const val = parseFloat(input.value) || 0
        subtotal += val
      }
    })

    const taxPct = parseFloat(this.element.querySelector("input[name='expense[tax_percent]']")?.value) || 0
    const tipPct = parseFloat(this.element.querySelector("input[name='expense[tip_percent]']")?.value) || 0
    const tax = (subtotal * taxPct / 100)
    const tip = (subtotal * tipPct / 100)
    const grand = subtotal + tax + tip

    const fmt = (n) => n.toFixed(2)
    if (this.hasSubtotalTarget) this.subtotalTarget.textContent = fmt(subtotal)
    if (this.hasTaxDisplayTarget) this.taxDisplayTarget.textContent = fmt(tax)
    if (this.hasTipDisplayTarget) this.tipDisplayTarget.textContent = fmt(tip)
    if (this.hasGrandTotalTarget) this.grandTotalTarget.textContent = fmt(grand)
  }
}
