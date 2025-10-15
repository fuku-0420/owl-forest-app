import { Controller } from "@hotwired/stimulus"

// 🦉 横画面固定＋縦向き警告メッセージ用コントローラ
export default class extends Controller {
    connect() {
        this.forceLandscape()
        this.setupOrientationWarning()
    }

    // =========================================
    // 📱 向きが縦に戻ったときの警告表示
    // =========================================
    setupOrientationWarning() {
        const showNotice = () => {
            const angle = screen.orientation?.angle ?? window.orientation ?? 0
            const type = screen.orientation?.type ?? ""

            // portrait系 or angleが0/180なら警告を出す
            if (type.startsWith("portrait") || angle === 0 || angle === 180) {
                const notice = document.createElement("div")
                notice.textContent = "横向き推奨です🦉🌳"

                Object.assign(notice.style, {
                    position: "fixed",
                    top: "40%",
                    left: "50%",
                    transform: "translate(-50%, -50%)",
                    background: "rgba(0,0,0,0.7)",
                    color: "white",
                    padding: "16px 24px",
                    borderRadius: "12px",
                    fontSize: "20px",
                    zIndex: "9999",
                    textAlign: "center",
                    fontFamily: "'游ゴシック', 'Hiragino Kaku Gothic ProN', sans-serif",
                    transition: "opacity 0.4s ease",
                })

                document.body.appendChild(notice)

                // 💨 2秒後にフェードアウトして削除
                setTimeout(() => {
                    notice.style.opacity = "0"
                    setTimeout(() => notice.remove(), 400)
                }, 2000)
            }
        }

        // 新仕様
        if (screen.orientation && "onchange" in screen.orientation) {
            screen.orientation.onchange = showNotice
        } else {
            // 後方互換フォールバック
            window.addEventListener("orientationchange", showNotice)
        }
    }

    // =========================================
    // 🧭 横画面固定（Android Chrome / PWA用）
    // =========================================
    async forceLandscape() {
        try {
            const ua = navigator.userAgent

            // 💻 PCではスキップ
            if (!/Mobi|Android|iPhone|iPad|Tablet/i.test(ua)) {
                console.log("💻 PC環境のため orientation.lock はスキップしました。")
                return
            }

            // 🍎 iOS Safari は非対応（CSSで対応）
            if (/iPhone|iPad|iPod/i.test(ua)) {
                console.log("🍎 iOS Safari では orientation.lock は未対応のため CSS で回転処理します。")
                return
            }

            // 📱 Android Chrome / PWA ならロック可能
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
