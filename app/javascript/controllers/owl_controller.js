import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["blackboard", "owlCard", "typingText", "forest"]
  static values = {
    categories: Array,
    signedIn: Boolean,
    favoriteIds: Array
  }

  static storageKey = "fukuchan_board_state"

  // ===== Timer / Audio =====
  sharedAudioCtx = null

  // 物語用（interval と timeout を分離）
  storyIntervalId = null
  storyTimeoutId = null

  // アドバイス本文用（setTimeoutチェーン）
  adviceTimeoutId = null

  // 梟メッセージ用（複数setTimeout）
  owlTimeoutIds = []

  // Enter画面のタイピング
  typingInterval = null

  isHappyMode = false
  canClickFukuchan = false

  saveBoardState(state) {
    try {
      sessionStorage.setItem(this.constructor.storageKey, JSON.stringify(state))
    } catch (e) {
      console.log("saveBoardState failed:", e.message)
    }
  }

  clearBoardState() {
    try {
      sessionStorage.removeItem(this.constructor.storageKey)
    } catch (e) {
      // noop
    }
  }

  restoreBoardState() {
    try {
      const raw = sessionStorage.getItem(this.constructor.storageKey)
      if (!raw) return false

      const state = JSON.parse(raw)
      if (!state || state.view !== "category_list") return false

      const categories = this.categoriesValue || []
      const category = categories.find(c => Number(c.id) === Number(state.categoryId))
      if (!category) return false

      this.showAdviceList(category, { fromRestore: true })
      return true
    } catch (e) {
      console.log("restoreBoardState failed:", e.message)
      return false
    }
  }

  getSettings() {
    try {
      return JSON.parse(sessionStorage.getItem("fukuchan_settings") || "{}")
    } catch (_) {
      return {}
    }
  }

  isTypingEnabled() {
    const s = this.getSettings()
    return s.typingEnabled !== false // デフォルトON
  }

  isSfxEnabled() {
    const s = this.getSettings()
    return s.sfxEnabled !== false // デフォルトON
  }

  // ピコピコを鳴らしていい条件（効果音設定だけを見る）
  shouldPlayTypingSfx() {
    return this.isSfxEnabled()
  }

  // ===== Cleanup helpers =====
  stopStory() {
    if (this.storyIntervalId) {
      clearInterval(this.storyIntervalId)
      this.storyIntervalId = null
    }
    if (this.storyTimeoutId) {
      clearTimeout(this.storyTimeoutId)
      this.storyTimeoutId = null
    }
  }

  stopAdviceTyping() {
    if (this.adviceTimeoutId) {
      clearTimeout(this.adviceTimeoutId)
      this.adviceTimeoutId = null
    }
  }

  stopOwlMessages() {
    if (this.owlTimeoutIds && this.owlTimeoutIds.length > 0) {
      this.owlTimeoutIds.forEach(id => clearTimeout(id))
      this.owlTimeoutIds = []
    }
  }

  connect() {
    this.applyBackgroundSetting()
    const params = new URLSearchParams(window.location.search)
    this.fromBoardReturn = params.get("board") === "1"

    // ① 掲示板へ戻る：相談室へ直行（演出なし）
    if (this.fromBoardReturn) {
      this.showConsultationRoom({ fromReturn: true })
      history.replaceState({}, "", window.location.pathname)
      return
    }

    // ② 保存状態があれば復元（カテゴリ一覧へ直行）
    const restored = this.restoreBoardState()
    if (restored) return

    // ③ それ以外は通常演出
    this.startTypingAnimation()

    const unlockAudio = () => {
      try {
        const ctx = window._sharedAudioContext
        if (ctx && ctx.state === "suspended") ctx.resume()
      } catch (e) { }
      window.removeEventListener("click", unlockAudio)
    }
    window.addEventListener("click", unlockAudio, { once: true })
  }

  applyBackgroundSetting() {
    if (!this.hasForestTarget) return

    const el = this.forestTarget

    let settings = {}
    try {
      settings = JSON.parse(sessionStorage.getItem("fukuchan_settings") || "{}")
    } catch (_) { }

    const mode = settings.bgMode || "auto"
    let resolved = mode

    // 自動設定：時間帯で切り替え
    // 5:00〜10:59  → 春（朝）
    // 11:00〜15:59 → 夏（昼）
    // 16:00〜18:59 → 秋（夕方）
    // 19:00〜4:59  → 冬（夜）
    if (mode === "auto") {
      const hour = new Date().getHours()

      if (hour >= 5 && hour < 11) {
        resolved = "spring"
      } else if (hour >= 11 && hour < 16) {
        resolved = "summer"
      } else if (hour >= 16 && hour < 19) {
        resolved = "autumn"
      } else {
        resolved = "winter"
      }
    }

    let nextSrc = el.dataset.summerImage

    if (resolved === "spring") {
      nextSrc = el.dataset.springImage
    } else if (resolved === "summer") {
      nextSrc = el.dataset.summerImage
    } else if (resolved === "autumn") {
      nextSrc = el.dataset.autumnImage
    } else if (resolved === "winter") {
      nextSrc = el.dataset.winterImage
    } else if (resolved === "yoru") {
      nextSrc = el.dataset.yoruImage
    }

    if (!nextSrc) return
    el.src = nextSrc
  }

  startTypingAnimation() {
    const text = "🦉知識の森へようこそ🦉"
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
    this.typingTextTarget.parentElement.classList.add("typing-complete")
  }

  enterForest() {
    console.log("森に入ります！")

    // 設定を読む
    let settings = {}
    try {
      settings = JSON.parse(sessionStorage.getItem("fukuchan_settings") || "{}")
    } catch (_) { }

    const bgmPopupEnabled = settings.bgmPopup !== false

    // BGM 再生判断
    const bgmController = this.application.getControllerForElementAndIdentifier(
      document.querySelector("[data-controller='bgm']"),
      "bgm"
    )

    let allowPlay = false
    if (bgmPopupEnabled) {
      allowPlay = confirm("この先、BGMが再生されます。\n再生しますか？")
    }

    if (allowPlay && bgmController && !bgmController.isPlaying) {
      bgmController.toggle()
    }

    // 演出スタート
    this.fadeOutButton()

    setTimeout(() => {
      this.showWelcomeMessage()
    }, 1000)
  }

  fadeOutButton() {
    if (this.typingInterval) {
      clearInterval(this.typingInterval)
      this.typingInterval = null
    }

    document.querySelectorAll(".chalk-text-button").forEach(btn => {
      btn.classList.add("fade-out")
      btn.style.pointerEvents = "none"
      setTimeout(() => btn.remove(), 700)
    })
  }

  showWelcomeMessage() {
    const blackboard = this.blackboardTarget

    if (blackboard.querySelector(".welcome-message")) {
      console.log("既にメッセージが表示されています")
      return
    }

    // 物語開始前に「物語タイマー」を念のため止める（多重起動対策）
    this.stopStory()

    this.addStorySkipButton()

    const messageDiv = document.createElement("div")
    messageDiv.classList.add("welcome-message")
    blackboard.appendChild(messageDiv)

    this.showStoryAnimation(messageDiv)
  }

  showStoryAnimation(messageDiv) {
    const createTypingSound = () => {
      try {
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
        osc.frequency.value = 1000
        gain.gain.value = 0.025
        osc.start()
        osc.stop(this.sharedAudioCtx.currentTime + 0.03)
      } catch (e) {
        // 無音でOK
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

        this.stopStory()

        this.storyIntervalId = setInterval(() => {
          if (charIndex < combinedText.length) {
            if (combinedText[charIndex] === "\n") {
              messageDiv.innerHTML += "<br>"
            } else {
              messageDiv.innerHTML += combinedText[charIndex]
              if (combinedText[charIndex] !== " " && this.shouldPlayTypingSfx()) {
                createTypingSound()
              }
            }
            charIndex++
          } else {
            if (this.storyIntervalId) {
              clearInterval(this.storyIntervalId)
              this.storyIntervalId = null
            }

            currentLineIndex += linesToShow
            patternIndex++

            this.storyTimeoutId = setTimeout(showNextGroup, 2000)
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
    const existingSkip = document.querySelector(".story-skip-button")
    if (existingSkip) existingSkip.remove()

    const stopEverything = () => {
      this.stopStory()
      this.stopAdviceTyping()
      this.stopOwlMessages()

      if (this.sharedAudioCtx) {
        try { this.sharedAudioCtx.close() } catch (_) { }
        this.sharedAudioCtx = null
        window._sharedAudioContext = null
      }
    }

    const skipButton = document.createElement("button")
    skipButton.textContent = "skip"
    skipButton.classList.add("story-skip-button")

    skipButton.addEventListener("click", () => {
      if (confirm("物語をスキップしますか？")) {
        stopEverything()
        skipButton.remove()
        this.applyBackgroundSetting()
        this.showConsultationRoom()
      }
    })

    document.body.appendChild(skipButton)
  }

  fadeOutStory() {
    const messageDiv = this.blackboardTarget.querySelector(".welcome-message")
    if (!messageDiv) return

    // 物語タイマー停止
    this.stopStory()

    messageDiv.classList.add("fade-out")

    setTimeout(() => {
      messageDiv.remove()
      this.showConsultationRoom()
    }, 1000)
  }

  hoverOwl(event) {
    event.currentTarget.style.transform = "translateY(-10px)"
  }

  leaveOwl(event) {
    event.currentTarget.style.transform = "translateY(0)"
  }

  resetBlackboard() {
    this.blackboardTarget.replaceChildren()
  }

  showConsultationRoom({ fromReturn = false } = {}) {
    document.querySelectorAll(".story-skip-button").forEach(el => el.remove())

    // 画面切り替え時に残留タイマー止める
    this.stopStory()
    this.stopAdviceTyping()
    this.stopOwlMessages()

    this.resetBlackboard()

    if (this.typingInterval) {
      clearInterval(this.typingInterval)
      this.typingInterval = null
    }

    const blackboard = this.blackboardTarget

    const title = document.createElement("h2")
    title.textContent = "🦉 フクちゃん学習掲示板 🦉"
    title.classList.add("board-title")

    const categories = this.categoriesValue || []
    const buttonContainer = document.createElement("div")
    buttonContainer.classList.add("button-container")

    categories.forEach(category => {
      const btn = document.createElement("button")
      btn.textContent = category.name
      btn.classList.add("board-button")
      btn.addEventListener("click", () => this.showAdviceList(category))
      buttonContainer.appendChild(btn)
    })

    blackboard.appendChild(title)
    blackboard.appendChild(buttonContainer)

    if (!fromReturn) {
      title.style.opacity = "0"
      title.style.transform = "translateY(-30px)"
      title.style.transition = "all 0.8s cubic-bezier(0.4, 0, 0.2, 1)"
      setTimeout(() => {
        title.style.opacity = "1"
        title.style.transform = "translateY(0)"
      }, 100)
    }

    if (fromReturn) {
      //  戻ってきた時も日替わりを反映してから静的表示
      this.applyDailyMessageToFukuchanLines()
      this.showOwlProfileStatic()
      return
    }

    //  初期表示も日替わりを反映
    this.applyDailyMessageToFukuchanLines()

    this.addFukuchanImage()

    if (!this.profileInitialized) {
      this.showOwlProfile()
      this.profileInitialized = true
    }
  }

  showAdviceList(category, { fromRestore = false } = {}) {
    // 画面切り替え時に本文タイピング止める（連打対策）
    this.stopAdviceTyping()

    this.resetBlackboard()

    if (!fromRestore) {
      this.saveBoardState({ view: "category_list", categoryId: category.id })
    }

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
    backButton.classList.add("back-button", "visible")
    blackboard.appendChild(backButton)

    backButton.addEventListener("click", () => {
      this.clearBoardState()
      this.showConsultationRoom({ fromReturn: true })
    })
  }

  showAdviceDetail(advice, category) {
    // アドバイス詳細を開いたら笑顔にする
    this.setHappyMode()

    // 連打で多重にタイピングが走らないように止める
    this.stopAdviceTyping()

    this.resetBlackboard()
    const blackboard = this.blackboardTarget

    const textArea = document.createElement("div")
    textArea.classList.add("advice-text")
    blackboard.appendChild(textArea)

    this.typeText(textArea, advice.body || "", { speed: 50, withSound: true })

    if (this.signedInValue) {
      const favBtn = document.createElement("button")
      favBtn.classList.add("favorite-button")

      const ids = new Set((this.favoriteIdsValue || []).map(Number))
      const isFav = ids.has(Number(advice.id))
      favBtn.textContent = isFav ? "♥ 登録済み" : "♡ お気に入り"

      favBtn.addEventListener("click", async () => {
        const token = document.querySelector("meta[name='csrf-token']").content

        const res = await fetch("/favorites", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "X-CSRF-Token": token,
            "Accept": "application/json"
          },
          body: JSON.stringify({ favorite: { advice_id: advice.id } })
        })

        if (!res.ok) {
          alert("お気に入り登録に失敗しました")
          return
        }

        if (ids.has(Number(advice.id))) {
          ids.delete(Number(advice.id))
          favBtn.textContent = "♡ お気に入り"
        } else {
          ids.add(Number(advice.id))
          favBtn.textContent = "♥ 登録済み"
        }

        this.favoriteIdsValue = Array.from(ids)
      })

      blackboard.appendChild(favBtn)
    }

    const backButton = document.createElement("button")
    backButton.textContent = "戻る"
    backButton.classList.add("back-button", "visible")
    blackboard.appendChild(backButton)

    backButton.addEventListener("click", () => {
      this.stopAdviceTyping()
      this.setOriginalMode()
      this.showAdviceList(category)
      this.showOwlProfileStatic()
    })
  }

  addFavoriteButton(blackboard, adviceId) {
    if (!this.signedInValue) return

    const btn = document.createElement("button")
    btn.textContent = "♡ お気に入り"
    btn.classList.add("favorite-button")

    btn.addEventListener("click", async () => {
      const token = document.querySelector("meta[name='csrf-token']").content

      const res = await fetch("/favorites", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": token
        },
        body: JSON.stringify({ favorite: { advice_id: adviceId } })
      })

      if (res.ok) {
        btn.textContent = "♥ 登録済み"
        btn.disabled = true
      } else {
        alert("お気に入り登録に失敗しました")
      }
    })

    blackboard.appendChild(btn)
  }

  typeText(element, text, { speed = 50, withSound = false } = {}) {
    this.stopAdviceTyping()

    if (!this.isTypingEnabled()) {
      element.textContent = text
      // タイピングOFFでも最後に下へ
      requestAnimationFrame(() => this.scrollAdviceToBottom())
      return
    }

    let i = 0
    element.textContent = ""

    const tick = () => {
      if (i < text.length) {
        element.textContent = text.slice(0, i + 1) + "|"

        // 表示更新に合わせて追従スクロール
        requestAnimationFrame(() => this.scrollAdviceToBottom())

        if (withSound && this.shouldPlayTypingSfx() && text[i] !== " " && text[i] !== "\n") {
          this.createTypingSoundAdvice()
        }

        let delay = speed
        const c = text[i]
        if (c === "。" || c === "、" || c === "！" || c === "？") delay = speed * 10

        i++
        this.adviceTimeoutId = setTimeout(tick, delay)
      } else {
        element.textContent = text
        this.adviceTimeoutId = null

        requestAnimationFrame(() => this.scrollAdviceToBottom())
      }
    }

    tick()
  }

  addFukuchanImage() {
    const img = document.querySelector(".fukuchan-global")
    if (!img) return

    this.canClickFukuchan = false

    img.onclick = () => {
      if (!this.canClickFukuchan) return

      if (this.isHappyMode) {
        this.setOriginalMode()
      } else {
        this.setHappyMode()
      }
    }

    setTimeout(() => {
      img.classList.add("fukuchan-visible")
    }, 500)
  }

  switchToNewMessage() {
    const messageLines = document.querySelectorAll(".message-line")
    const fukuchanImg = document.querySelector(".fukuchan-global")

    if (messageLines.length >= 2) {
      const line1 = "僕に何か聞きたいっホ～？"
      const line2 = "頑張り屋さんっホウ〜🦉"

      messageLines[0].textContent = line1
      messageLines[1].textContent = line2

      messageLines[0].dataset.message = line1
      messageLines[1].dataset.message = line2

      if (fukuchanImg) fukuchanImg.src = fukuchanImg.dataset.happyImage
    }
  }

  getDailyOwlMessage() {
    const dailySets = [
      ["こんにちは！僕は梟🦉のフクちゃん", "知識の森へようこそだホウ〜"],
      ["ようこそ知識の森へ🦉", "今日はどんなヒントを探すホウ〜？"],
      ["こんにちは！また来てくれて嬉しいよ🦉", "ゆっくり森を歩いていくホウ〜"],
      ["困っていることはあるかな？🦉", "この森でヒントを見つけるホウ〜"],
      ["この掲示板には学びのヒントが集まっているよ🦉", "気になるカテゴリを見ていくホウ〜"],
      ["迷ったときはこの森に来るといいよ🦉", "一緒に整理していくホウ〜"],
      ["今日も来てくれてありがとう🦉", "焦らずゆっくり探していくホウ〜"],
      ["まずは好きなカテゴリから見てみよう🦉", "きっとヒントが見つかるホウ〜"],
      ["この森にはいろんなヒントが眠っているよ🦉", "気になるものを探していくホウ〜"],
      ["今日も一歩ずつ進んでいこう🦉", "小さなヒントが役に立つホウ〜"],
      ["気軽に見ていってね🦉", "この森はいつでも歓迎するホウ〜"],
      ["困ったときはまた来るといいよ🦉", "この森でヒントを探すホウ〜"],
      ["今日も頑張ってるね🦉", "少し休みながら進むホウ〜"],
    ]

    const index = Math.floor(Math.random() * dailySets.length)
    return dailySets[index]
  }

  applyDailyMessageToFukuchanLines() {
    const [line1, line2] = this.getDailyOwlMessage()
    const lines = document.querySelectorAll(".message-line")

    if (lines.length >= 2) {
      lines[0].dataset.message = line1
      lines[1].dataset.message = line2
    }
  }

  switchToOriginalMessage() {
    const messageLines = document.querySelectorAll(".message-line")
    const fukuchanImg = document.querySelector(".fukuchan-global")

    const [line1, line2] = this.getDailyOwlMessage()

    if (messageLines.length >= 2) {
      messageLines[0].textContent = line1
      messageLines[1].textContent = line2

      messageLines[0].dataset.message = line1
      messageLines[1].dataset.message = line2

      if (fukuchanImg) fukuchanImg.src = fukuchanImg.dataset.normalImage
    }
  }

  setHappyMode() {
    if (this.isHappyMode) return
    this.switchToNewMessage()
    this.isHappyMode = true
  }

  setOriginalMode() {
    if (!this.isHappyMode) return
    this.switchToOriginalMessage()
    this.isHappyMode = false
  }

  showOwlProfile() {
    const owlsContainer = document.querySelector(".owls-container")
    if (!owlsContainer) return

    owlsContainer.style.display = "block"
    owlsContainer.classList.add("hidden-init")

    setTimeout(() => {
      owlsContainer.classList.add("showing")

      setTimeout(() => {
        const owlCards = owlsContainer.querySelectorAll(".owl-card")
        owlCards.forEach(card => card.classList.add("show-floating"))

        setTimeout(() => {
          this.showAllOwlMessages()
        }, 500)
      }, 800)
    }, 1000)
  }

  showOwlProfileStatic() {
    const owlsContainer = document.querySelector(".owls-container")
    if (!owlsContainer) return

    owlsContainer.style.display = "block"
    owlsContainer.classList.remove("hidden-init")
    owlsContainer.classList.remove("showing")

    owlsContainer.querySelectorAll(".owl-card").forEach(card => card.classList.add("show-floating"))

    owlsContainer.querySelectorAll(".message-line").forEach(line => {
      if (line.textContent.trim() === "") {
        line.textContent = line.dataset.message || ""
      }
    })

    const img = document.querySelector(".fukuchan-global")
    if (img) {
      img.style.opacity = "1"
      img.style.display = "block"
      img.classList.add("fukuchan-visible")
      img.src = img.dataset.normalImage
    }
  }

  showAllOwlMessages() {
    this.stopOwlMessages()
    this.canClickFukuchan = false

    document.querySelectorAll(".message-line").forEach(line => {
      line.textContent = ""
    })

    const owlCards = document.querySelectorAll(".owl-card")

    owlCards.forEach((card, cardIndex) => {
      const id = setTimeout(() => {
        const messageLines = card.querySelectorAll(".message-line")
        const isLastCard = cardIndex === owlCards.length - 1
        this.showOwlMessages(messageLines, isLastCard)
      }, cardIndex * 500)

      this.owlTimeoutIds.push(id)
    })
  }

  showOwlMessages(messageLines, isLastCard = false) {
    messageLines.forEach((line, index) => {
      const isLastLine = isLastCard && index === messageLines.length - 1

      const id = setTimeout(() => {
        const message = line.dataset.message
        this.typeOwlMessage(line, message, isLastLine)
      }, index * 2500)

      this.owlTimeoutIds.push(id)
    })
  }

  typeOwlMessage(element, text, enableClickWhenDone = false) {
    let index = 0
    element.textContent = ""

    const typeWriter = () => {
      if (index < text.length) {
        element.textContent = text.substring(0, index + 1)

        if (text[index] !== " " && this.shouldPlayTypingSfx()) {
          this.createTypingSoundOwl()
        }

        let delay = 80
        const char = text[index]
        if (char === "！" || char === "!" || char === "？" || char === "、" || char === "。") {
          delay = 600
        }

        index++
        const id = setTimeout(typeWriter, delay)
        this.owlTimeoutIds.push(id)
      } else {
        if (enableClickWhenDone) {
          this.canClickFukuchan = true
        }
      }
    }

    typeWriter()
  }

  createTypingSoundOwl() {
    try {
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

  createTypingSoundAdvice() {
    try {
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

  scrollAdviceToBottom() {
    const el = this.element.querySelector(".advice-text")
    if (!el) return

    // ユーザーが手で上にスクロールして読んでる時は邪魔しない
    const nearBottom = (el.scrollHeight - el.scrollTop - el.clientHeight) < 40
    if (!nearBottom) return

    el.scrollTop = el.scrollHeight
  }

  disconnect() {
    console.log("🦉 Controller disconnected — cleaning up...")

    // 物語/本文/梟を全部止める
    this.stopStory()
    this.stopAdviceTyping()
    this.stopOwlMessages()

    if (this.typingInterval) {
      clearInterval(this.typingInterval)
      this.typingInterval = null
    }

    if (this.sharedAudioCtx && this.sharedAudioCtx.state !== "closed") {
      try { this.sharedAudioCtx.close() } catch (_) { }
      this.sharedAudioCtx = null
      window._sharedAudioContext = null
    }

    console.log("🧹 Cleaned up all audio & timers.")
  }
}
