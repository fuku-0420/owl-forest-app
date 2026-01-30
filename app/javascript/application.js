import "@hotwired/turbo-rails"
import "controllers"

// ===============================
// フクちゃん掲示板：背景管理（STEP1）
// ===============================
window.Fukuchan = window.Fukuchan || {}

/**
 * 背景画像を適用する（いまは夏だけ）
 * ※ まだ設定や季節判定はしない
 */
window.Fukuchan.applyBackground = () => {
  const forestImage = document.querySelector(".forest-bg")
  if (!forestImage) return

  const summerImage = forestImage.dataset.summerImage
  if (!summerImage) return

  forestImage.src = summerImage
}
