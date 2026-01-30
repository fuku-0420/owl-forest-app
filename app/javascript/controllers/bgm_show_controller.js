// app/javascript/controllers/bgm_show_controller.js
import { Controller } from "@hotwired/stimulus"

// ❄️ プロフィールページ専用・静かなBGMコントローラ（自動再生ブロック対策つき）
export default class extends Controller {
    static targets = ["toggleButton"]

    connect() {
        const bgmPath = this.element.dataset.bgmPath
        if (!bgmPath) return

        this.bgm = new Audio(bgmPath)
        this.bgm.loop = true

        // 📱 モバイルは音量低め
        const isMobile = /iPhone|iPad|iPod|Android/i.test(navigator.userAgent)
        this.defaultVolume = isMobile ? 0.035 : 0.15
        this.bgm.volume = this.defaultVolume

        // 連打耐性
        this._busy = false

        // クリックで再生するためのハンドラを保持（remove用）
        this._resumeHandler = this._resumeByUserGesture.bind(this)

        // index側で「再生しない」を選んだなら自動再生しない
        const enabled = sessionStorage.getItem("bgmEnabled")
        if (enabled === "false") {
            this.isPlaying = false
            if (this.hasToggleButtonTarget) this.toggleButtonTarget.textContent = "BGM再生"
            return
        }

        // OK なら自動再生を試す（失敗したら「次のクリックで再生」を仕込む）
        this._startPlay()
    }

    disconnect() {
        document.removeEventListener("click", this._resumeHandler)
        this.stopBgm()
        this.bgm = null
    }

    toggle() {
        if (!this.bgm) return
        if (this._busy) return

        if (this.isPlaying) {
            this._busy = true
            document.removeEventListener("click", this._resumeHandler)
            this.stopBgm()
            this.isPlaying = false
            if (this.hasToggleButtonTarget) this.toggleButtonTarget.textContent = "BGM再生"
            sessionStorage.setItem("bgmEnabled", "false")
            this._busy = false
        } else {
            this._busy = true
            this._startPlay().finally(() => {
                this._busy = false
            })
        }
    }

    // ▶️ 再生開始（自動再生ブロック時は click 待ちに切り替える）
    _startPlay() {
        if (!this.bgm) return Promise.resolve()

        this.bgm.volume = this.defaultVolume

        return this.bgm.play()
            .then(() => {
                this.isPlaying = true
                document.removeEventListener("click", this._resumeHandler)
                if (this.hasToggleButtonTarget) this.toggleButtonTarget.textContent = "BGM停止"
                sessionStorage.setItem("bgmEnabled", "true")
            })
            .catch(() => {
                // 🛑 自動再生ブロック
                this.isPlaying = false
                if (this.hasToggleButtonTarget) {
                    this.toggleButtonTarget.textContent = "BGM再生（タップで開始）"
                }
                sessionStorage.setItem("bgmEnabled", "true")

                // 次のユーザー操作(クリック)で再生を再トライ
                document.removeEventListener("click", this._resumeHandler)
                document.addEventListener("click", this._resumeHandler, { once: true })
            })
    }

    // ✅ ユーザー操作で再開（ブロック回避）
    _resumeByUserGesture() {
        if (!this.bgm) return
        if (this.isPlaying) return

        this._startPlay()
    }

    // ⏹ 停止
    stopBgm() {
        if (!this.bgm) return
        this.bgm.pause()
        this.bgm.currentTime = 0
    }
}
