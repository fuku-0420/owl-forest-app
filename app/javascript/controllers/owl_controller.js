import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["blackboard", "owlCard", "typingText"]
  static values = { categories: Array }

  // ★ タイマー管理用のプロパティを追加
  currentTimer = null
  sharedAudioCtx = null

  connect() {
    this.startTypingAnimation()

    // 🎧 Mac Safari用オーディオ解放
    const unlockAudio = () => {
      try {
        const ctx = window._sharedAudioContext
        if (ctx && ctx.state === "suspended") {
          ctx.resume()
          console.log("🔓 AudioContext resumed")
        }
      } catch (e) {
        console.log("Audio unlock failed:", e.message)
      }
      window.removeEventListener("click", unlockAudio)
    }
    window.addEventListener("click", unlockAudio, { once: true })
  }

  startTypingAnimation() {
    const text = "🦉RUNTEQ 知識の森へようこそ🦉"
    const typingElement = this.typingTextTarget

    typingElement.textContent = ""

    let index = 0
    this.typingInterval = setInterval(() => {
      if (index < text.length) {
        typingElement.textContent += text[index]
        index++
      } else {
        clearInterval(this.typingInterval)
        this.typingInterval = null
        this.enableButton()
      }
    }, 100)
  }

  enableButton() {
    this.typingTextTarget.parentElement.classList.add('typing-complete')
  }

  enterForest() {
    console.log("森に入ります！")

    // 🔊 BGMコントローラーを探して再生
    const bgmController = this.application.getControllerForElementAndIdentifier(
      document.querySelector("[data-controller='bgm']"),
      "bgm"
    )

    if (bgmController && !bgmController.isPlaying) {
      bgmController.toggle()
    }

    // ボタンを消すアニメーション
    this.fadeOutButton()

    // 少し待ってから物語を表示
    setTimeout(() => {
      this.showWelcomeMessage()
    }, 1000)
  }

  fadeOutButton() {
    // ★ タイピングを完全停止
    if (this.typingInterval) {
      clearInterval(this.typingInterval)
      this.typingInterval = null
    }

    // ★ chalk-text-button を全削除
    document.querySelectorAll('.chalk-text-button').forEach(btn => {
      btn.classList.add('fade-out')
      btn.style.pointerEvents = 'none'
      setTimeout(() => btn.remove(), 700)
    })
  }

  showWelcomeMessage() {
    const blackboard = this.blackboardTarget

    if (blackboard.querySelector('.welcome-message')) {
      console.log("既にメッセージが表示されています")
      return
    }

    // スキップボタン追加
    this.addStorySkipButton()

    // メッセージ領域生成
    const messageDiv = document.createElement('div')
    messageDiv.classList.add('welcome-message')
    blackboard.appendChild(messageDiv)

    // 物語アニメーション開始
    this.showStoryAnimation(messageDiv)
  }


  showStoryAnimation(messageDiv) {
    const createTypingSound = () => {
      try {
        if (!this.sharedAudioCtx) {
          this.sharedAudioCtx = new AudioContext()
        }

        if (this.sharedAudioCtx.state === 'suspended') {
          this.sharedAudioCtx.resume()
        }

        const osc = this.sharedAudioCtx.createOscillator()
        const gain = this.sharedAudioCtx.createGain()
        osc.connect(gain)
        gain.connect(this.sharedAudioCtx.destination)
        osc.frequency.value = 1000
        gain.gain.value = 0.025
        osc.start()
        osc.stop(this.sharedAudioCtx.currentTime + 0.03)
      } catch (e) {
        // エラー時は無音
      }
    }

    const storyLines = [
      "ここは..           知識の森...   ",
      "世界の知識が集まる場所...             ",
      "生物たちは..",
      "森に救いを求めてやって来る...      ",
      "今日も..",
      "一羽の梟が新しいことを学んでる...   ",
      "誰かの役に立ちたくて...      ",
      "迷える人を救いたくて...",
      "正しい道へ...     帰れるように..."
    ]

    const displayPattern = [1, 1, 1, 1, 1, 1, 2, 1]

    let currentLineIndex = 0
    let patternIndex = 0

    const showNextGroup = () => {
      if (currentLineIndex < storyLines.length && patternIndex < displayPattern.length) {
        const linesToShow = displayPattern[patternIndex]

        let combinedText = ""
        for (let i = 0; i < linesToShow && (currentLineIndex + i) < storyLines.length; i++) {
          if (i > 0) combinedText += "\n"
          combinedText += storyLines[currentLineIndex + i]
        }

        messageDiv.innerHTML = ""

        let charIndex = 0
        this.currentTimer = setInterval(() => {
          if (charIndex < combinedText.length) {
            if (combinedText[charIndex] === '\n') {
              messageDiv.innerHTML += '<br>'
            } else {
              messageDiv.innerHTML += combinedText[charIndex]
              if (combinedText[charIndex] !== ' ') {
                createTypingSound()
              }
            }
            charIndex++
          } else {
            clearInterval(this.currentTimer)
            this.currentTimer = null
            currentLineIndex += linesToShow
            patternIndex++
            this.currentTimer = setTimeout(showNextGroup, 2000)
          }
        }, 80)
      } else {
        console.log("物語表示完了！")
        this.fadeOutStory()
      }
    }

    showNextGroup()
  }

  addStorySkipButton() {
    const existingSkip = document.querySelector('.story-skip-button')
    if (existingSkip) existingSkip.remove()

    const stopEverything = () => {
      if (this.currentTimer) {
        clearInterval(this.currentTimer)
        clearTimeout(this.currentTimer)
        this.currentTimer = null
      }
      if (this.sharedAudioCtx) {
        this.sharedAudioCtx.close()
        this.sharedAudioCtx = null
      }
    }

    const skipButton = document.createElement('button')
    skipButton.textContent = 'skip'
    skipButton.classList.add('story-skip-button')

    skipButton.addEventListener('click', () => {
      if (confirm('物語をスキップしますか？')) {
        stopEverything()
        skipButton.remove()

        const classroomContainer = document.querySelector('.classroom-container')
        const forestImage = classroomContainer?.querySelector('.forest-bg')

        if (forestImage) {
          // HTML内の data-autumn-image 属性を使ってパスを安全に取得
          const autumnImage = forestImage.dataset.autumnImage

          // 秋画像に切り替え（フェード演出）
          forestImage.style.transition = 'opacity 0.8s ease'
          forestImage.style.opacity = '0'

          setTimeout(() => {
            forestImage.src = autumnImage
            forestImage.style.opacity = '1'
          }, 500)
        }

        this.showConsultationRoom()
      }
    })
    document.body.appendChild(skipButton)
  }

  fadeOutStory() {
    const messageDiv = this.blackboardTarget.querySelector('.welcome-message')
    if (!messageDiv) return

    messageDiv.classList.add('fade-out')

    setTimeout(() => {
      messageDiv.remove()
      this.showConsultationRoom()
    }, 1000)
  }

  // フクロウカードのホバー効果
  hoverOwl(event) {
    event.currentTarget.style.transform = 'translateY(-10px)'
  }

  leaveOwl(event) {
    event.currentTarget.style.transform = 'translateY(0)'
  }

  resetBlackboard() {
    // 黒板内は完全リセット
    this.blackboardTarget.replaceChildren()
  }

  showConsultationRoom() {
    document.querySelectorAll('.story-skip-button').forEach(el => el.remove())
    this.resetBlackboard()

    console.log("掲示板表示開始！")

    if (this.typingInterval) {
      clearInterval(this.typingInterval)
      this.typingInterval = null
    }

    const blackboard = this.blackboardTarget

    // ===== 黒板タイトル =====
    const title = document.createElement('h2')
    title.textContent = '🦉 フクちゃんお悩み掲示板 🦉'
    title.classList.add('board-title')

    // ===== ボタン名リスト =====
    const categories = this.categoriesValue || []

    const buttonContainer = document.createElement('div')
    buttonContainer.classList.add('button-container')

    categories.forEach(category => {
      const btn = document.createElement('button')
      btn.textContent = category.name
      btn.classList.add('board-button')

      btn.addEventListener('click', () => {
        this.showAdviceList(category)
      })

      buttonContainer.appendChild(btn)
    })

    blackboard.appendChild(title)
    blackboard.appendChild(buttonContainer)

    title.style.opacity = '0'
    title.style.transform = 'translateY(-30px)'
    title.style.transition = 'all 0.8s cubic-bezier(0.4, 0, 0.2, 1)'

    setTimeout(() => {
      title.style.opacity = '1'
      title.style.transform = 'translateY(0)'
    }, 100)

    this.addFukuchanImage()

    if (!this.profileInitialized) {
      this.showOwlProfile()
      this.profileInitialized = true
    }
  }

  showAdviceList(category) {
    this.resetBlackboard()

    const blackboard = this.blackboardTarget

    const title = document.createElement("h2")
    title.textContent = `📌 ${category.name}`
    title.classList.add("board-title")

    const buttonContainer = document.createElement("div")
    buttonContainer.classList.add("button-container")

    const advices = category.advices || []

    if (advices.length === 0) {
      const empty = document.createElement("div")
      empty.classList.add("advice-text")
      empty.textContent = "このカテゴリにはまだアドバイスがありません。"
      blackboard.appendChild(title)
      blackboard.appendChild(empty)
    } else {
      advices.forEach(advice => {
        const btn = document.createElement("button")
        btn.textContent = advice.title
        btn.classList.add("board-button")

        btn.addEventListener("click", () => {
          this.showAdviceDetail(advice, category)
        })

        buttonContainer.appendChild(btn)
      })

      blackboard.appendChild(title)
      blackboard.appendChild(buttonContainer)
    }

    const backButton = document.createElement("button")
    backButton.textContent = "戻る"
    backButton.classList.add("back-button")
    backButton.classList.add("visible")
    blackboard.appendChild(backButton)

    backButton.addEventListener("click", () => {
      this.showConsultationRoom()
    })
  }

  showAdviceDetail(advice, category) {
    this.resetBlackboard()
    const blackboard = this.blackboardTarget

    const textArea = document.createElement("div")
    textArea.classList.add("advice-text")
    blackboard.appendChild(textArea)

    // 本文をタイピング表示
    this.typeText(textArea, advice.body || "", { speed: 50, withSound: true })

    const backButton = document.createElement("button")
    backButton.textContent = "戻る"
    backButton.classList.add("back-button", "visible")
    blackboard.appendChild(backButton)

    backButton.addEventListener("click", () => {
      // 戻るときにタイピング止める
      if (this.currentTimer) {
        clearTimeout(this.currentTimer)
        this.currentTimer = null
      }
      this.showAdviceList(category)
    })
  }

  typeText(element, text, { speed = 50, withSound = false } = {}) {
    if (this.currentTimer) {
      clearTimeout(this.currentTimer)
      this.currentTimer = null
    }

    let i = 0
    element.textContent = ""

    const tick = () => {
      if (i < text.length) {
        element.textContent = text.slice(0, i + 1) + "|"

        if (withSound && text[i] !== " " && text[i] !== "\n") {
          this.createTypingSoundAdvice()
        }

        let delay = speed
        const c = text[i]
        if (c === "。" || c === "、" || c === "！" || c === "？") {
          delay = speed * 10
        }

        i++
        this.currentTimer = setTimeout(tick, delay)
      } else {
        element.textContent = text
        this.currentTimer = null
      }
    }

    tick()
  }

  addFukuchanImage() {
    const img = document.querySelector('.fukuchan-global')
    if (!img) return

    let showOriginal = true
    let canClick = false

    img.onclick = () => {
      if (!canClick) return

      if (showOriginal) {
        this.switchToNewMessage()
      } else {
        this.switchToOriginalMessage()
      }
      showOriginal = !showOriginal
    }

    // ★ 表示アニメーション完了後（fukuchan-visibleをHTML/CSSと連携）
    setTimeout(() => {
      img.classList.add('fukuchan-visible')

      setTimeout(() => {
        canClick = true
      }, 10000)//　10秒後クリック
    }, 500)
  }

  switchToNewMessage() {
    const messageLines = document.querySelectorAll('.message-line')
    const fukuchanImg = document.querySelector('.fukuchan-global')

    if (messageLines.length >= 2) {
      // 💬 セリフ切り替え
      messageLines[0].textContent = '僕に何か聞きたいっホ～？'
      messageLines[1].textContent = '頑張り屋さんっホウ〜🦉'

      // 🖼️ 画像切り替え
      if (fukuchanImg) {
        fukuchanImg.src = fukuchanImg.dataset.happyImage
      }
    }
  }

  switchToOriginalMessage() {
    const messageLines = document.querySelectorAll('.message-line')
    const fukuchanImg = document.querySelector('.fukuchan-global')

    if (messageLines.length >= 2) {
      // 💬 セリフを元に戻す
      messageLines[0].textContent = 'こんにちは！僕は梟🦉のフクちゃん'
      messageLines[1].textContent = '沢山の人を笑顔にするのが仕事だホウ〜☆彡'

      // 🖼️ 画像を元に戻す
      if (fukuchanImg) {
        fukuchanImg.src = fukuchanImg.dataset.normalImage
      }
    }
  }

  showOwlProfile() {
    const owlsContainer = document.querySelector('.owls-container')

    if (owlsContainer) {
      owlsContainer.style.display = 'block'
      owlsContainer.classList.add('hidden-init')

      setTimeout(() => {
        owlsContainer.classList.add('showing')

        setTimeout(() => {
          const owlCards = owlsContainer.querySelectorAll('.owl-card')
          owlCards.forEach(card => card.classList.add('show-floating'))

          setTimeout(() => {
            this.showAllOwlMessages()
          }, 500)
        }, 800)
      }, 1000)
    }
  }

  // ★ 梟のメッセージを自動表示
  showAllOwlMessages() {
    const owlCards = document.querySelectorAll('.owl-card')

    owlCards.forEach((card, cardIndex) => {
      const id = setTimeout(() => {
        const messageLines = card.querySelectorAll('.message-line')
        this.showOwlMessages(messageLines)
      }, cardIndex * 500) // カードごとに0.5秒遅延

      // タイマー追跡
      if (!this.activeTimeouts) this.activeTimeouts = []
      this.activeTimeouts.push(id)
    })
  }

  // 梟メッセージを順番に音付きで表示
  showOwlMessages(messageLines) {
    messageLines.forEach((line, index) => {
      const id = setTimeout(() => {
        const message = line.dataset.message
        this.typeOwlMessage(line, message)
      }, index * 2500) // 2.5秒ずつ遅延

      // タイマー追跡
      if (!this.activeTimeouts) this.activeTimeouts = []
      this.activeTimeouts.push(id)
    })
  }

  // 音付きタイプライター効果
  typeOwlMessage(element, text) {
    let index = 0
    element.textContent = ""

    const typeWriter = () => {
      if (index < text.length) {
        element.textContent = text.substring(0, index + 1)

        // 音を鳴らす（スペースは鳴らさない）
        if (text[index] !== ' ') {
          this.createTypingSoundOwl()
        }

        // 🔹 句読点で少し間を入れる
        let delay = 80 // 通常速度
        const char = text[index]
        if (char === '！' || char === '!' || char === '？' || char === '、' || char === '。') {
          delay = 600 // 0.6秒くらい一時停止
        }

        index++
        const id = setTimeout(typeWriter, delay)
        if (!this.activeTimeouts) this.activeTimeouts = []
        this.activeTimeouts.push(id)
      }
    }

    typeWriter()
  }

  // 🦉 フクロウのタイプ音
  createTypingSoundOwl() {
    try {
      // 1️⃣ 共通AudioContextを再利用
      if (!this.sharedAudioCtx) {
        this.sharedAudioCtx = window._sharedAudioContext || new (window.AudioContext || window.webkitAudioContext)()
        window._sharedAudioContext = this.sharedAudioCtx
      }

      if (this.sharedAudioCtx.state === "suspended") {
        this.sharedAudioCtx.resume()
      }

      const osc = this.sharedAudioCtx.createOscillator()
      const gain = this.sharedAudioCtx.createGain()

      osc.connect(gain)
      gain.connect(this.sharedAudioCtx.destination)

      osc.type = "sine"
      osc.frequency.value = 760 + Math.random() * 40

      gain.gain.setValueAtTime(0.1, this.sharedAudioCtx.currentTime)
      gain.gain.exponentialRampToValueAtTime(0.0001, this.sharedAudioCtx.currentTime + 0.06)

      osc.start()
      osc.stop(this.sharedAudioCtx.currentTime + 0.06)
    } catch (e) {
      console.log("音の再生ができませんでした(Owl):", e.message)
    }
  }

  // ⚙️ アドバイス（黒板メッセージ）用のタイプ音
  createTypingSoundAdvice() {
    try {
      // 同じ共有コンテキストを利用
      if (!this.sharedAudioCtx) {
        this.sharedAudioCtx = window._sharedAudioContext || new (window.AudioContext || window.webkitAudioContext)()
        window._sharedAudioContext = this.sharedAudioCtx
      }

      if (this.sharedAudioCtx.state === "suspended") {
        this.sharedAudioCtx.resume()
      }

      const osc = this.sharedAudioCtx.createOscillator()
      const gain = this.sharedAudioCtx.createGain()

      osc.connect(gain)
      gain.connect(this.sharedAudioCtx.destination)

      osc.type = "square"
      osc.frequency.value = 700 + Math.random() * 25
      gain.gain.setValueAtTime(0.025, this.sharedAudioCtx.currentTime)
      gain.gain.exponentialRampToValueAtTime(0.0001, this.sharedAudioCtx.currentTime + 0.06)

      osc.start()
      osc.stop(this.sharedAudioCtx.currentTime + 0.06)
    } catch (e) {
      console.log("音の再生ができませんでした(Advice):", e.message)
    }
  }

  // === Turboなどでページ遷移時に確実に呼ぶ ===
  disconnect() {
    console.log("🦉 Controller disconnected — cleaning up...");

    // すべての setTimeout を停止（タイピング含む）
    if (this.activeTimeouts && this.activeTimeouts.length > 0) {
      this.activeTimeouts.forEach(id => clearTimeout(id));
      this.activeTimeouts = [];
    }

    // setInterval, animationFrame も停止
    if (this.typingInterval) {
      clearInterval(this.typingInterval);
      this.typingInterval = null;
    }
    if (this.animationFrame) {
      cancelAnimationFrame(this.animationFrame);
      this.animationFrame = null;
    }

    // AudioContext を閉じて音を止める
    if (this.audioCtx && this.audioCtx.state !== "closed") {
      try {
        this.audioCtx.close();
      } catch (_) { }
      this.audioCtx = null;
    }

    if (this.audioCtxAdvice && this.audioCtxAdvice.state !== "closed") {
      try {
        this.audioCtxAdvice.close();
      } catch (_) { }
      this.audioCtxAdvice = null;
    }

    console.log("🧹 Cleaned up all audio & timers.");
  }
}