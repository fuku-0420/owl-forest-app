import { Controller } from "@hotwired/stimulus"

// ❄️ プロフィールページ専用・静かなBGMコントローラ
export default class extends Controller {
    static targets = ["toggleButton"]

    connect() {
        const bgmPath = this.element.dataset.bgmPath
        this.bgm = new Audio(bgmPath)
        this.bgm.loop = true

        // 📱 モバイルでは音量をさらに下げる（スマホスピーカー対策）
        const isMobile = /iPhone|iPad|iPod|Android/i.test(navigator.userAgent)
        this.defaultVolume = isMobile ? 0.035 : 0.15
        this.bgm.volume = this.defaultVolume

        // 🌙 ページが開かれたら自動再生を試みる（失敗時は静かに待機）
        this.bgm.play()
            .then(() => {
                this.isPlaying = true
                this.toggleButtonTarget.textContent = "BGM停止"
            })
            .catch(() => {
                // 🕊️ ブラウザ制限（自動再生ブロック）の場合はボタン待機
                this.isPlaying = false
                this.toggleButtonTarget.textContent = "BGM再生"
            })
    }

    disconnect() {
        if (this.bgm) {
            this.bgm.pause()
            this.bgm.currentTime = 0
            this.bgm = null
        }
    }

    toggle() {
        if (!this.bgm) return

        if (this.isPlaying) {
            this.fadeOutAndPause()
            this.isPlaying = false
            this.toggleButtonTarget.textContent = "BGM再生"
        } else {
            // 🌱 再生時はフェードインして自然に鳴らす
            this.bgm.volume = 0
            this.bgm.play().then(() => {
                this.fadeInToVolume(this.defaultVolume)
                this.isPlaying = true
                this.toggleButtonTarget.textContent = "BGM停止"
            })
        }
    }

    // 🌾 フェードイン処理
    fadeInToVolume(targetVolume) {
        let v = 0
        const fade = setInterval(() => {
            v += 0.01
            if (v >= targetVolume) {
                v = targetVolume
                clearInterval(fade)
            }
            if (this.bgm) this.bgm.volume = v
        }, 100)
    }

    // 🍂 フェードアウトして停止
    fadeOutAndPause() {
        if (!this.bgm) return
        let v = this.bgm.volume
        const fade = setInterval(() => {
            v -= 0.01
            if (v <= 0.01) {
                clearInterval(fade)
                this.bgm.pause()
                this.bgm.volume = this.defaultVolume
            } else {
                this.bgm.volume = v
            }
        }, 100)
    }
}