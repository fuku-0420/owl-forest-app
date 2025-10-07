import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display"]

  connect() {
    this.updateClock();
    this.clockInterval = setInterval(() => this.updateClock(), 1000);
  }

  disconnect() {
    if (this.clockInterval) {
      clearInterval(this.clockInterval);
    }
  }

  updateClock() {
    const now = new Date();
    const options = {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit',
      weekday: 'long'
    };

    const dateTimeString = now.toLocaleDateString('ja-JP', options);
    this.displayTarget.textContent = dateTimeString;
  }
}