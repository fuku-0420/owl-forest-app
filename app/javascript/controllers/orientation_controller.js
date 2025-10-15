import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        this.forceLandscape()
    }

    async forceLandscape() {
        try {
            // 💡 PCではスキップ（モバイル判定）
            const isMobile = /Mobi|Android|iPhone|iPad|Tablet/i.test(navigator.userAgent)
            if (!isMobile) {
                console.log("💻 PC環境のため orientation.lock はスキップしました。")
                return
            }

            // 💡 iOS Safari は orientation.lock 非対応
            const isIOS = /iPhone|iPad|iPod/i.test(navigator.userAgent)
            if (isIOS) {
                console.log("🍎 iOS Safari では orientation.lock は未対応のため CSS で回転処理します。")
                return
            }

            // 💡 Android Chrome / PWA 環境のみロック実行
            if (screen.orientation && screen.orientation.lock) {
                await screen.orientation.lock("landscape")
                console.log("📱 横画面に固定しました。")
            } else {
                console.log("⚠️ orientation.lock 未対応ブラウザです。")
            }
        } catch (e) {
            console.warn("orientation.lockエラー:", e.message)
        }
    }
}