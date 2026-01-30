import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["bgMode", "bgmPopup", "sfx", "typing"]

    connect() {
        console.log("アプリ設定開きました。")

        const saved = this.loadSettings()

        // 背景
        const bgMode = saved.bgMode || "auto"
        if (this.hasBgModeTarget) this.bgModeTarget.value = bgMode

        // BGMポップアップ（表示用）
        const bgmPopup = saved.bgmPopup ?? true
        if (this.hasBgmPopupTarget) this.bgmPopupTarget.textContent = bgmPopup ? "ON" : "OFF"

        // 効果音（表示用）
        const sfxEnabled = saved.sfxEnabled ?? true
        if (this.hasSfxTarget) this.sfxTarget.textContent = sfxEnabled ? "ON" : "OFF"

        // タイピング演出（表示用）
        const typingEnabled = saved.typingEnabled ?? true
        if (this.hasTypingTarget) this.typingTarget.textContent = typingEnabled ? "ON" : "OFF"
    }

    // 背景設定の変更（保存のみ）
    changeBackground() {
        if (!this.hasBgModeTarget) return
        const mode = this.bgModeTarget.value
        this.saveSettings({ bgMode: mode })
    }

    // BGMポップアップのON/OFF（保存のみ）
    toggleBgmPopup() {
        const saved = this.loadSettings()
        const next = !(saved.bgmPopup ?? true)
        this.saveSettings({ bgmPopup: next })
        if (this.hasBgmPopupTarget) this.bgmPopupTarget.textContent = next ? "ON" : "OFF"
    }

    // 効果音ON/OFF（保存のみ）
    toggleSfx() {
        const saved = this.loadSettings()
        const next = !(saved.sfxEnabled ?? true)
        this.saveSettings({ sfxEnabled: next })
        if (this.hasSfxTarget) this.sfxTarget.textContent = next ? "ON" : "OFF"
    }

    // タイピング演出ON/OFF（保存のみ）
    toggleTyping() {
        const saved = this.loadSettings()
        const next = !(saved.typingEnabled ?? true)
        this.saveSettings({ typingEnabled: next })
        if (this.hasTypingTarget) this.typingTarget.textContent = next ? "ON" : "OFF"
    }

    // =========================
    // sessionStorage 共通
    // =========================
    settingsKey() {
        return "fukuchan_settings"
    }

    loadSettings() {
        try {
            return JSON.parse(sessionStorage.getItem(this.settingsKey()) || "{}")
        } catch {
            return {}
        }
    }

    saveSettings(patch) {
        const current = this.loadSettings()
        const next = { ...current, ...patch }
        sessionStorage.setItem(this.settingsKey(), JSON.stringify(next))
        return next
    }
  /*
   * 将来拡張メモ：
   *
   * bgMode の候補
   * - "auto"    : 時間帯 or 季節で自動切替
   * - "summer"  : 常に夏
   * - "autumn"  : 常に秋
   * - "winter"  : 常に冬（予定）
   * - "spring"  : 常に春（予定）
   *
   * ※ 実際の判定・画像切替は owl_controller 側で行う
   */
}
