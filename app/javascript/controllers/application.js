import { Application } from "@hotwired/stimulus"

const application = Application.start()
application.debug = false
window.Stimulus = application

export { application }

// ✅ Turboページ切り替え時にクラスを制御
document.addEventListener("turbo:load", () => {
    const path = window.location.pathname
    const html = document.documentElement
    const body = document.body

    if (path.match(/^\/owls\/\d+$/)) {
        body.classList.add("owl-show-page")
        html.classList.add("owl-show-page")
    } else {
        body.classList.remove("owl-show-page")
        html.classList.remove("owl-show-page")
    }
})

// function adjustBlackboardPosition() {
//     const blackboard = document.querySelector('.blackboard')
//     if (!blackboard) return
//
//     const vw = window.innerWidth
//     const vh = window.innerHeight
//     const topPercent = 0.39
//
//     blackboard.style.transition = 'top 0.5s ease'
//     blackboard.style.left = `${vw * 0.49}px`
//     blackboard.style.top = `${vh * topPercent}px`
//     blackboard.style.transform = 'translate(-50%, -50%)'
// }
//
// window.addEventListener('resize', () => {
//     adjustBlackboardPosition()
//     setTimeout(adjustBlackboardPosition, 700)
//     setTimeout(adjustBlackboardPosition, 1300)
// })
// window.addEventListener('load', adjustBlackboardPosition)