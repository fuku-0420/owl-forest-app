import { Controller } from "@hotwired/stimulus"

// 🎵 BGMコントローラ（即再生/即停止版）
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

    this.bgm.volume = this.clampVolume(volume)

    if (this.hasVolumeSliderTarget) {
      this.volumeSliderTarget.value = this.bgm.volume
    }

    this.isPlaying = false
    this.updateUi()
  }

  disconnect() {
    this.stopImmediate({ resetTime: true })
    this.bgm = null
  }

  //  押したら即 再生 / 即 停止
  toggle() {
    if (!this.bgm) return

    if (this.isPlaying) {
      this.stopImmediate({ resetTime: true })
      this.isPlaying = false
      this.updateUi()
      return
    }

    // 再生（即）
    this.bgm.play()
      .then(() => {
        this.isPlaying = true
        this.updateUi()
      })
      .catch(error => {
        console.error("BGM play failed:", error)
        this.isPlaying = false
        this.updateUi()
      })
  }

  // 🎚️ スライダー操作で音量調整（安全リミッター付き）
  adjustVolume() {
    if (!this.bgm || !this.hasVolumeSliderTarget) return

    const safeVolume = this.clampVolume(parseFloat(this.volumeSliderTarget.value))
    this.bgm.volume = safeVolume
    localStorage.setItem("bgmVolume", safeVolume)
  }

  // -------------------------
  // 内部ユーティリティ
  // -------------------------
  clampVolume(v) {
    const n = Number.isFinite(v) ? v : 0.15
    return Math.min(Math.max(n, 0.0), 0.3)
  }

  stopImmediate({ resetTime = true } = {}) {
    if (!this.bgm) return
    this.bgm.pause()
    if (resetTime) this.bgm.currentTime = 0
  }

  updateUi() {
    if (this.hasToggleButtonTarget) {
      this.toggleButtonTarget.textContent = this.isPlaying ? "BGM停止" : "BGMを再生"
    }

    // 見た目用（任意：CSSで playing を使って強調できる）
    this.element.classList.toggle("playing", this.isPlaying)
  }
}
