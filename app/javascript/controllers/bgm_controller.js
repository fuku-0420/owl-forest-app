import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["toggleButton", "volumeSlider"]

  connect() {
    // Railsがプリコンパイルした正しいURLを取得する
    const bgmPath = this.element.dataset.bgmPath
    this.bgm = new Audio(bgmPath)
    this.bgm.loop = true
    this.bgm.volume = parseFloat(this.volumeSliderTarget?.value || 0.2)
    this.isPlaying = false
  }

  disconnect() {
    if (this.bgm) {
      this.bgm.pause()
      this.bgm.currentTime = 0
      this.bgm = null
    }
  }

  toggle() {
    if (this.isPlaying) {
      this.fadeOutAndPause()
      this.toggleButtonTarget.textContent = '森のBGM'
      this.element.classList.remove('playing')
      this.isPlaying = false
    } else {
      this.bgm.play().then(() => {
        this.toggleButtonTarget.textContent = 'BGM停止'
        this.isPlaying = true
        this.element.classList.add('playing')
      }).catch(error => {
        console.error('BGM play failed:', error)
      })
    }
  }

  fadeOutAndPause() {
    if (!this.bgm) return
    const originalVolume = this.bgm.volume
    let currentVolume = originalVolume

    const fade = setInterval(() => {
      currentVolume -= 0.02
      if (currentVolume <= 0.01) {
        clearInterval(fade)
        this.bgm.pause()
        this.bgm.currentTime = 0
        this.bgm.volume = originalVolume
        return
      }
      this.bgm.volume = Math.max(currentVolume, 0)
    }, 100)
  }

  adjustVolume() {
    if (this.bgm) {
      this.bgm.volume = this.volumeSliderTarget.value
    }
  }
}
