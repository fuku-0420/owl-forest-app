// app/javascript/controllers/bgm_controller.js
import { Controller } from "@hotwired/stimulus"

// 🌳 森ページ用 BGM（即再生/即停止 + 音量スライダー + 「詳しく見る」遷移前confirm）
export default class extends Controller {
  static targets = ["toggleButton", "volumeSlider"]

  connect() {
    if (!this.element.classList.contains("bgm-controls")) return
    const bgmPath = this.element.dataset.bgmPath
    if (!bgmPath) return

    this.bgm = new Audio(bgmPath)
    this.bgm.loop = true

    // 連打耐性
    this._busy = false

    // 📱スマホは音量控えめ
    const isMobile = /iPhone|iPad|iPod|Android/i.test(navigator.userAgent)
    const defaultVolume = isMobile ? 0.05 : 0.15

    // 🔁 音量復元（森用）
    const savedVolume = localStorage.getItem("bgmVolume")
    const volume = savedVolume ? parseFloat(savedVolume) : defaultVolume
    this.bgm.volume = this._clampVolume(volume)

    if (this.hasVolumeSliderTarget) this.volumeSliderTarget.value = this.bgm.volume

    // 初期停止
    this.isPlaying = false
    this._updateUi()
  }

  disconnect() {
    this._stop({ resetTime: true })
    this.bgm = null
  }

  toggle() {
    if (!this.bgm) return
    if (this._busy) return
    this._busy = true

    if (this.isPlaying) {
      this._stop({ resetTime: true })
      this.isPlaying = false
      this._updateUi()
      this._busy = false
      return
    }

    this.bgm.play()
      .then(() => {
        this.isPlaying = true
        this._updateUi()
      })
      .catch((e) => {
        console.error("BGM play failed:", e)
        this.isPlaying = false
        this._updateUi()
      })
      .finally(() => {
        this._busy = false
      })
  }

  adjustVolume() {
    if (!this.bgm || !this.hasVolumeSliderTarget) return
    const v = this._clampVolume(parseFloat(this.volumeSliderTarget.value))
    this.bgm.volume = v
    localStorage.setItem("bgmVolume", v)
  }

  // ✅ 「詳しく見る」クリック時：show側BGMを流すか確認してから遷移
  confirmBeforeNavigate(event) {
    event.preventDefault()
    const url = event.currentTarget.href

    const play = window.confirm(
      "この先のプロフィールページでBGMが流れます。\n再生しますか？\n\nOK：再生する\nキャンセル：再生しない"
    )

    sessionStorage.setItem("bgmEnabled", play ? "true" : "false")

    // 森BGMは「止めたいなら止める」派ならここで止める
    // （不要ならこの3行消してOK）
    if (this.isPlaying) {
      this._stop({ resetTime: true })
      this.isPlaying = false
      this._updateUi()
    }

    window.location.href = url
  }

  // -------------------------
  // 内部
  // -------------------------
  _clampVolume(v) {
    const n = Number.isFinite(v) ? v : 0.15
    return Math.min(Math.max(n, 0.0), 0.3)
  }

  _stop({ resetTime = true } = {}) {
    if (!this.bgm) return
    this.bgm.pause()
    if (resetTime) this.bgm.currentTime = 0
  }

  _updateUi() {
    if (this.hasToggleButtonTarget) {
      this.toggleButtonTarget.textContent = this.isPlaying ? "BGM停止" : "BGM再生"
    }
    this.element.classList.toggle("playing", this.isPlaying)
  }
}
