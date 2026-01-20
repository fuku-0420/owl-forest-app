import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  comingSoon(event) {
    const feature = event.currentTarget.dataset.feature || "この機能"
    alert(`${feature} は開発中です！`)
  }
}