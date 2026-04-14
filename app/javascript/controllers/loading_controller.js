import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        this.minimumDuration = 550 // 最低表示時間（ミリ秒）
        this.hide = this.stop.bind(this)

        const loader = document.getElementById("loading")
        const startedAt = Number(sessionStorage.getItem("loadingStartedAt"))

        if (loader && startedAt) {
            loader.classList.remove("hidden")
        } else if (loader) {
            loader.classList.add("hidden")
        }

        document.addEventListener("turbo:load", this.hide)
        document.addEventListener("turbo:render", this.hide)
    }

    disconnect() {
        document.removeEventListener("turbo:load", this.hide)
        document.removeEventListener("turbo:render", this.hide)
    }

    start() {
        const loader = document.getElementById("loading")
        if (!loader) return

        sessionStorage.setItem("loadingStartedAt", String(Date.now()))
        loader.classList.remove("hidden")
    }

    stop() {
        const loader = document.getElementById("loading")
        if (!loader) return

        const startedAt = Number(sessionStorage.getItem("loadingStartedAt"))

        if (!startedAt) {
            loader.classList.add("hidden")
            return
        }

        const elapsed = Date.now() - startedAt
        const remaining = this.minimumDuration - elapsed

        if (remaining > 0) {
            setTimeout(() => {
                loader.classList.add("hidden")
                sessionStorage.removeItem("loadingStartedAt")
            }, remaining)
        } else {
            loader.classList.add("hidden")
            sessionStorage.removeItem("loadingStartedAt")
        }
    }
}
