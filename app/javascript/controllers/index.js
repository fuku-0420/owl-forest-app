import { application } from "./application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"

// 自動読み込み
eagerLoadControllersFrom("controllers", application)

// エラーハンドリング付きの手動登録
const registerController = async (name, controllerPath) => {
  try {
    const controller = await import(controllerPath)
    application.register(name, controller.default)
    console.log(`✅ ${name}コントローラー登録成功`)
  } catch (error) {
    console.warn(`⚠️ ${name}コントローラー読み込み失敗:`, error)
  }
}

// 手動登録（フォールバック）
registerController("owl", "./owl_controller")
registerController("bgm", "./bgm_controller")
registerController("clock", "./clock_controller")
registerController("hello", "./hello_controller")

console.log("🦉 Stimulusコントローラー初期化完了")