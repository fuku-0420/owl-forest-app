import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["toggleButton", "volumeSlider"]

  connect() {
    this.bgm = new Audio('/forest_ambient.mp3')
    this.bgm.loop = true
    this.bgm.volume = 0.3
    this.isPlaying = false

    this.bgm.addEventListener('loadeddata', () => {
      console.log('BGM file loaded successfully!')
    })

    this.bgm.addEventListener('error', (e) => {
      console.error('BGM file failed to load:', e)
    })
  }

  // ★ 追加！コントローラーが切断される時の処理
  disconnect() {
    console.log('BGMコントローラーが切断されます')
    if (this.bgm) {
      this.bgm.pause()
      this.bgm.currentTime = 0  // 再生位置もリセット
      this.bgm = null  // オブジェクトも削除
    }
  }

  toggle() {
    if (this.isPlaying) {
      this.bgm.pause()
      this.toggleButtonTarget.textContent = '森のBGM'
    } else {
      this.bgm.play().then(() => {
        console.log('BGM started playing')
        this.toggleButtonTarget.textContent = 'BGM停止'
        this.isPlaying = true
      }).catch(error => {
        console.error('BGM play failed:', error)
        alert('BGMファイルが見つかりません。ファイルの配置を確認してください。')
      })
      return
    }
    this.isPlaying = !this.isPlaying
  }

  adjustVolume() {
    if (this.bgm) {
      this.bgm.volume = this.volumeSliderTarget.value
    }
  }
}