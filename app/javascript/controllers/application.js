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