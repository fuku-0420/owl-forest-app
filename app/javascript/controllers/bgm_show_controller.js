import { Controller } from "@hotwired/stimulus"

// ❄️ プロフィールページ専用の静かなBGMコントローラー
export default class extends Controller {
    static targets = ["toggleButton"]

    connect() {
        // ✅ Railsが生成するfingerprint付きのURLを使う
        const bgmPath = this.element.dataset.bgmPath

        this.bgm = new Audio(bgmPath)
        this.bgm.loop = true
        this.bgm.volume = 0.15

        // 🌙 ページが開かれたら自動スタート
        this.bgm.play().then(() => {
            this.isPlaying = true
            this.toggleButtonTarget.textContent = 'BGM停止'
        }).catch(() => {
            // ユーザー操作が必要なブラウザ制限時に対応
            this.isPlaying = false
            this.toggleButtonTarget.textContent = 'BGM再生'
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
        if (this.isPlaying) {
            this.bgm.pause()
            this.isPlaying = false
            this.toggleButtonTarget.textContent = 'BGM再生'
        } else {
            this.bgm.play()
            this.isPlaying = true
            this.toggleButtonTarget.textContent = 'BGM停止'
        }
    }
}
