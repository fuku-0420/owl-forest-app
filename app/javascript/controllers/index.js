import { application } from "./application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"

// 全てのコントローラーを自動読み込み
eagerLoadControllersFrom("controllers", application)

// 手動登録（確実に動作させるため）
import OwlController from "./owl_controller"
import BgmController from "./bgm_controller"
import ClockController from "./clock_controller"
import HelloController from "./hello_controller"

application.register("owl", OwlController)
application.register("bgm", BgmController)
application.register("clock", ClockController)
application.register("hello", HelloController)

console.log("🦉 Stimulusコントローラー登録完了")