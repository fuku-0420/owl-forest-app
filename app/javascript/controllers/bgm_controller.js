import { Controller } from "@hotwired/stimulus"

// 🎵 BGMコントローラ
export default class extends Controller {
  static targets = ["toggleButton", "volumeSlider"]

  connect() {
    const bgmPath = this.element.dataset.bgmPath
    this.bgm = new Audio(bgmPath)
    this.bgm.loop = true

    // 📱スマホでは音量を下げめに設定
    const isMobile = /iPhone|iPad|iPod|Android/i.test(navigator.userAgent)
    const defaultVolume = isMobile ? 0.04 : 0.25

    // 🔁 前回の音量を復元（localStorage使用）
    const savedVolume = localStorage.getItem("bgmVolume")
    const volume = savedVolume ? parseFloat(savedVolume) : defaultVolume

    this.bgm.volume = volume
    if (this.volumeSliderTarget) this.volumeSliderTarget.value = volume
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
      this.toggleButtonTarget.textContent = "森のBGM"
      this.element.classList.remove("playing")
      this.isPlaying = false
    } else {
      // 再生時はフェードインで自然に音が出る
      this.bgm.volume = 0
      this.bgm.play().then(() => {
        this.fadeInToTargetVolume()
        this.toggleButtonTarget.textContent = "BGM停止"
        this.element.classList.add("playing")
        this.isPlaying = true
      }).catch(error => {
        console.error("BGM play failed:", error)
      })
    }
  }

  // 🎧 フェードアウトして停止
  fadeOutAndPause() {
    if (!this.bgm) return
    const originalVolume = this.bgm.volume
    let currentVolume = originalVolume

    const fade = setInterval(() => {
      currentVolume -= 0.015
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

  // 🌱 フェードインで音量を上げる
  fadeInToTargetVolume() {
    const target = Math.min(parseFloat(this.volumeSliderTarget?.value || 0.15), 0.3)
    let v = 0
    const fade = setInterval(() => {
      v += 0.01
      if (v >= target) {
        v = target
        clearInterval(fade)
      }
      this.bgm.volume = v
    }, 100)
  }

  // 🎚️ スライダー操作で音量調整（安全リミッター付き）
  adjustVolume() {
    if (this.bgm) {
      const safeVolume = Math.min(Math.max(parseFloat(this.volumeSliderTarget.value), 0.0), 0.3)
      this.bgm.volume = safeVolume
      localStorage.setItem("bgmVolume", safeVolume)
    }
  }
}