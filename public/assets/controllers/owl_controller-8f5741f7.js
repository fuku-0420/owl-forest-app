import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["blackboard", "owlCard", "typingText"]

  // ★ タイマー管理用のプロパティを追加
  currentTimer = null
  sharedAudioCtx = null

  connect() {
    this.startTypingAnimation()
  }

  startTypingAnimation() {
    const text = "🦉RUNTEQ 知識の森へようこそ🦉"
    const typingElement = this.typingTextTarget

    typingElement.textContent = ""

    let index = 0
    const typeInterval = setInterval(() => {
      if (index < text.length) {
        typingElement.textContent += text[index]
        index++
      } else {
        clearInterval(typeInterval)
        this.enableButton()
      }
    }, 100)
  }

  enableButton() {
    this.typingTextTarget.parentElement.classList.add('typing-complete')
  }

  enterForest() {
    console.log("森に入ります！")
    this.fadeOutButton()
    setTimeout(() => {
      this.showWelcomeMessage()
    }, 1000)
  }

  fadeOutButton() {
    const button = this.typingTextTarget.parentElement
    button.style.opacity = '0'
    button.style.transition = 'opacity 0.5s ease-out'
    button.style.pointerEvents = 'none'
    button.disabled = true
  }

  showWelcomeMessage() {
    const blackboard = this.blackboardTarget

    if (blackboard.querySelector('.welcome-message')) {
      console.log("既にメッセージが表示されています")
      return
    }

    this.addStorySkipButton()

    const messageDiv = document.createElement('div')
    messageDiv.classList.add('welcome-message')
    messageDiv.style.fontSize = '24px'
    messageDiv.style.color = '#ffff40ff'
    messageDiv.style.textAlign = 'center'
    messageDiv.style.marginTop = '-50px'
    messageDiv.style.lineHeight = '1.8'

    blackboard.appendChild(messageDiv)

    // ★ 物語アニメーション開始
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
        gain.gain.value = 0.02
        osc.start()
        osc.stop(this.sharedAudioCtx.currentTime + 0.03)
      } catch (e) {
        // エラー時は無音
      }
    }

    const storyLines = [
      "ここは..           知識の森...   ",
      "世界の知識が集まる場所...             ",
      "生物たちは..              森に救いを求めてやって来る...      ",
      "今日も..",
      "一羽の梟が新しいことを学んでる...   ",
      "誰かの役に立ちたくて...      ",
      "迷える人を救いたくて...",
      "正しい道へ...     帰れるように..."
    ]

    const displayPattern = [1, 1, 1, 1, 1, 2, 1]

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

    const blackboard = this.blackboardTarget
    const skipButton = document.createElement('button')
    skipButton.textContent = 'skip'
    skipButton.classList.add('story-skip-button')
    skipButton.style.position = 'absolute'
    skipButton.style.top = '300px'
    skipButton.style.right = '10px'
    skipButton.style.padding = '10px 15px'
    skipButton.style.backgroundColor = '#15823517'
    skipButton.style.color = 'black'
    skipButton.style.border = 'none'
    skipButton.style.borderRadius = '5px'
    skipButton.style.cursor = 'pointer'
    skipButton.style.zIndex = '1000'
    skipButton.style.transition = 'all 0.3s ease'

    skipButton.addEventListener('mouseenter', () => {
      skipButton.style.backgroundColor = '#d9ab2ca6'
      skipButton.style.color = 'white'
      skipButton.style.transform = 'scale(1.1)'
    })

    skipButton.addEventListener('mouseleave', () => {
      skipButton.style.backgroundColor = '#15823517'
      skipButton.style.color = 'black'
      skipButton.style.transform = 'scale(1)'
    })

    // スキップ機能
    skipButton.addEventListener('click', () => {
      if (confirm('物語をスキップしますか？')) {
        stopEverything()

        // 背景を秋に変更
        const classroomContainer = document.querySelector('.classroom-container')
        if (classroomContainer) {
          classroomContainer.classList.add('autumn')
        }

        this.showConsultationRoom()
      }
    })

    blackboard.appendChild(skipButton)
  }

  fadeOutStory() {
    const messageDiv = this.blackboardTarget.querySelector('.welcome-message')
    messageDiv.style.transition = 'opacity 1s ease-out'
    messageDiv.style.opacity = '0'

    // フェードアウト完了後に相談室を表示
    setTimeout(() => {
      this.showConsultationRoom()
    }, 1000)
  }

  showConsultationRoom() {
    // 相談室表示の処理をここに書く
    console.log("相談室を表示します")
    // 必要に応じて実装してください
  }

  // フクロウカードのホバー効果
  hoverOwl(event) {
    event.currentTarget.style.transform = 'translateY(-10px)'
  }

  leaveOwl(event) {
    event.currentTarget.style.transform = 'translateY(0)'
  }

  showConsultationRoom() {
    console.log("掲示板表示開始！")

    const blackboard = this.blackboardTarget

    // 物語のdivを削除（お掃除）
    const welcomeMessage = blackboard.querySelector('.welcome-message')
    if (welcomeMessage) {
      welcomeMessage.remove()
    }

    const skipButton = blackboard.querySelector('.story-skip-button')
    if (skipButton) {
      skipButton.remove()
    }

    const title = document.createElement('h2')
    title.textContent = '🦉 フクちゃんお悩み掲示板 🦉'
    title.style.color = '#fcc900ff'
    title.style.textAlign = 'center'
    title.style.fontSize = 'clamp(20px, 4vw, 28px)'
    title.style.marginTop = 'clamp(-150px, -25vh, -250px)'
    title.style.position = 'relative'
    title.style.left = '3px'

    // ★ レスポンシブ対応のボタン作成
    const button = document.createElement('button')
    button.textContent = '☢エラー大量発生☢'
    button.style.backgroundColor = '#00ffe183'
    button.style.color = '#e23030ff'
    button.style.position = 'absolute'
    button.style.left = '49%'
    button.style.transform = 'translateX(-50%)'      // ★ 中央配置の確実な実装
    button.style.top = 'clamp(250px, 40vh, 350px)'  // ★ 画面の高さに応じて調整
    button.style.padding = 'clamp(10px, 2vw, 15px) clamp(20px, 4vw, 30px)'  // ★ レスポンシブパディング
    button.style.border = 'none'
    button.style.borderRadius = '50px'
    button.style.boxShadow = '0 8px 20px rgba(53, 189, 199, 0.81)'
    button.style.cursor = 'pointer'
    button.style.fontSize = 'clamp(16px, 3vw, 20px)'  // ★ レスポンシブフォントサイズ
    button.style.fontWeight = 'bold'
    button.style.transition = 'all 0.3s ease'

    // ホバー効果（変更なし）
    button.addEventListener('mouseenter', () => {
      button.style.transform = 'translateX(-50%) scale(1.1)'
      button.style.backgroundColor = '#00f2ffff'
    })

    button.addEventListener('mouseleave', () => {
      button.style.transform = 'translateX(-50%) scale(1) '
      button.style.backgroundColor = '#3cc5caff'
    })

    document.body.appendChild(title)      // 1番目
    document.body.appendChild(button)     // 2番目

    button.addEventListener('click', () => {
      title.style.transition = 'all 0.5s ease-out'
      title.style.opacity = '0'
      button.style.transition = 'all 0.5s ease-out'
      button.style.opacity = '0'

      setTimeout(() => {
        title.style.display = 'none'
        button.style.display = 'none'

        const advice = `現在の作業ブランチ内で修正できなかった場合は
  新しいブランチを切ってリモートから前データを取得するといい

    大切なのは課題を見直してクリアしてから
    何がエラーの原因だったのか理解することだよ‼

    失敗したブランチと比較してみてね‼
    エラーが出ても焦らずやっていこう(o^―^o)`

        // テキスト表示エリア作成
        const textArea = document.createElement('div')
        textArea.style.position = 'absolute'
        textArea.style.top = '25%'
        textArea.style.left = '51%'
        textArea.style.transform = 'translateX(-50%)'
        textArea.style.color = '#fcc900ff'
        textArea.style.fontSize = '18px'
        textArea.style.lineHeight = '1.8'
        textArea.style.fontFamily = 'monospace'
        textArea.style.width = '600px'
        textArea.style.minHeight = '400px'
        textArea.style.textAlign = 'left'
        textArea.style.maxWidth = '80%'
        textArea.style.whiteSpace = 'pre-line'
        textArea.style.textShadow = '2px 2px 4px rgba(0,0,0,0.8)'

        document.body.appendChild(textArea)

        // ★ backButton作成！
        const backButton = document.createElement('button')
        backButton.textContent = '戻る'
        backButton.style.position = 'absolute'
        backButton.style.top = '55%'
        backButton.style.left = '62.7%'
        backButton.style.transform = 'translateX(-50%)'
        backButton.style.padding = '10px 20px'
        backButton.style.backgroundColor = '#fcca001d'
        backButton.style.color = '#ffd500ff'
        backButton.style.border = 'none'
        backButton.style.borderRadius = '50px'
        backButton.style.cursor = 'pointer'
        backButton.style.opacity = '0'
        backButton.style.transition = 'all 0.3s ease'

        // ★ ホバー効果を追加！
        backButton.addEventListener('mouseenter', () => {
          backButton.style.transform = 'translateX(-50%) translateY(-4px) scale(1.05)'
          backButton.style.backgroundColor = '#ffea0054'
          backButton.style.boxShadow = '0 8px 20px rgba(255, 221, 0, 0.07)'
        })

        backButton.addEventListener('mouseleave', () => {
          backButton.style.transform = 'translateX(-50%) translateY(0) scale(1)'
          backButton.style.backgroundColor = '#fcca0025'
          backButton.style.boxShadow = 'none'
        })

        // ★ クリック時の押下効果！
        backButton.addEventListener('mousedown', () => {
          backButton.style.transform = 'translateX(-50%) translateY(1px) scale(0.98)'
        })

        backButton.addEventListener('mouseup', () => {
          backButton.style.transform = 'translateX(-50%) translateY(-4px) scale(1.05)'
        })

        // ★ backButtonのイベントリスナーも設定！
        backButton.addEventListener('click', () => {
          textArea.remove()
          backButton.remove()
          title.style.display = 'block'
          button.style.display = 'block'
          title.style.opacity = '1'
          button.style.opacity = '1'
        })

        // ★ backButtonをDOMに追加！
        document.body.appendChild(backButton)

        let index = 0
        const typeWriterWithSound = () => {
          if (index < advice.length) {
            textArea.textContent = advice.substring(0, index + 1) + '|'

            // 前のコードスタイルに合わせた音声機能
            const createTypingSound = () => {
              try {
                // 共有AudioContextがなければ作成
                if (!window.sharedAudioCtx) {
                  window.sharedAudioCtx = new AudioContext()
                }

                // サスペンド状態なら復帰
                if (window.sharedAudioCtx.state === 'suspended') {
                  window.sharedAudioCtx.resume()
                }

                const osc = window.sharedAudioCtx.createOscillator()
                const gain = window.sharedAudioCtx.createGain()
                osc.connect(gain)
                gain.connect(window.sharedAudioCtx.destination)
                osc.frequency.value = 850
                gain.gain.value = 0.02
                osc.start()
                osc.stop(window.sharedAudioCtx.currentTime + 0.05)
              } catch (e) {
                // エラー時は無音
              }
            }

            // スペースや改行以外で音を鳴らす
            if (advice[index] !== ' ' && advice[index] !== '\n') {
              createTypingSound()
            }

            index++
            setTimeout(typeWriterWithSound, 70)
          } else {
            textArea.textContent = advice
            setTimeout(() => {
              backButton.style.opacity = '1'
            }, 500)
          }
        }

        typeWriterWithSound()

      }, 500)
    })

    // 🆕 アニメーション用の初期設定
    title.style.opacity = '0'
    title.style.transform = 'translateY(-30px)'
    title.style.transition = 'all 0.8s cubic-bezier(0.4, 0, 0.2, 1)'

    blackboard.appendChild(title)

    // 🆕 少し遅れてアニメーション開始
    setTimeout(() => {
      title.style.opacity = '1'
      title.style.transform = 'translateY(0)'
    }, 100)

    //フクちゃん登場
    this.addFukuchanImage()
    setTimeout(() => {
      this.showOwlProfile()
    }, 2000)
  }

  addFukuchanImage() {
    const img = document.createElement('img')
    img.src = '/fukuchan.png'
    img.alt = 'フクちゃん'
    img.className = 'fukuchan-image'
    img.style.cursor = 'pointer'

    let showOriginal = true
    let canClick = false  // ★ 最初はクリック無効

    img.onclick = () => {
      if (!canClick) return  // ★ クリック無効中は何もしない

      if (showOriginal) {
        this.switchToNewMessage()
      } else {
        this.switchToOriginalMessage()
      }
      showOriginal = !showOriginal
    }

    document.body.appendChild(img)

    // ★ 表示アニメーション完了後
    setTimeout(() => {
      img.classList.add('fukuchan-visible')

      setTimeout(() => {
        canClick = true
      }, 7500)  // 7.5秒後にクリック可能

    }, 500)
  }

  switchToNewMessage() {
    const messageLines = document.querySelectorAll('.message-line')
    const fukuchanImg = document.querySelector('.fukuchan-image')

    if (messageLines.length >= 2) {
      messageLines[0].textContent = '僕に何か聞きたいっホ～？'
      messageLines[1].textContent = '頑張り屋さんっホウ〜🦉'

      // ★ 最初の画像と同じパス形式に統一
      fukuchanImg.src = '/fukuchan-happy.png'  // ルートパスで統一
    }
  }

  switchToOriginalMessage() {
    const messageLines = document.querySelectorAll('.message-line')
    const fukuchanImg = document.querySelector('.fukuchan-image')

    if (messageLines.length >= 2) {
      messageLines[0].textContent = 'こんにちは！僕は梟🦉のフクちゃん'
      messageLines[1].textContent = 'たくさんの人を笑顔にするのが仕事だホウ〜☆彡'

      // ★ 元のパスと完全に一致させる
      fukuchanImg.src = '/fukuchan.png'
    }
  }

  showOwlProfile() {
    const owlsContainer = document.querySelector('.owls-container')

    if (owlsContainer) {
      // 最初は非表示状態に設定
      owlsContainer.style.opacity = '0'
      owlsContainer.style.transform = 'translateY(20px)'
      owlsContainer.style.transition = 'all 0.8s ease-in-out'
      owlsContainer.style.display = 'block'

      // 登場アニメーション（フクちゃん画像の後に登場）
      setTimeout(() => {
        owlsContainer.style.opacity = '1'
        owlsContainer.style.transform = 'translateY(0px)'

        // ふわふわアニメーション開始
        setTimeout(() => {
          const owlCards = owlsContainer.querySelectorAll('.owl-card')
          owlCards.forEach(card => {
            card.classList.add('show-floating')
          })

          // ★ 梟カード表示後、自動でメッセージ表示開始
          setTimeout(() => {
            this.showAllOwlMessages()
          }, 500) // 梟カード登場から0.5秒後

        }, 800)
      }, 1000) // 1秒後に登場
    }
  }

  // ★ 全ての梟のメッセージを自動表示
  showAllOwlMessages() {
    const owlCards = document.querySelectorAll('.owl-card')

    owlCards.forEach((card, cardIndex) => {
      // 各カードのメッセージを少しずつ遅延して表示
      setTimeout(() => {
        const messageLines = card.querySelectorAll('.message-line')
        this.showOwlMessages(messageLines)
      }, cardIndex * 500) // カードごとに0.5秒遅延
    })
  }

  // 梟メッセージを順番に音付きで表示
  showOwlMessages(messageLines) {
    messageLines.forEach((line, index) => {
      setTimeout(() => {
        const message = line.dataset.message
        this.typeOwlMessage(line, message)
      }, index * 3500) // 3.5秒ずつ遅延
    })
  }

  // 音付きタイプライター効果（変更なし）
  typeOwlMessage(element, text) {
    let index = 0
    element.textContent = ""

    const typeWriter = () => {
      if (index < text.length) {
        element.textContent = text.substring(0, index + 1)

        if (text[index] !== ' ') {
          this.createTypingSound()
        }

        index++
        setTimeout(typeWriter, 80)
      }
    }

    typeWriter()
  }

  // 音を生成する（変更なし）
  createTypingSound() {
    try {
      const audioCtx = new (window.AudioContext || window.webkitAudioContext)()
      const osc = audioCtx.createOscillator()
      const gain = audioCtx.createGain()

      osc.connect(gain)
      gain.connect(audioCtx.destination)

      osc.frequency.value = 700
      gain.gain.value = 0.03

      osc.start()
      osc.stop(audioCtx.currentTime + 0.05)
    } catch (e) {
      console.log('音の再生ができませんでした:', e.message)
    }
  }
}

