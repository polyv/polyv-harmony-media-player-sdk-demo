import window from '@ohos.window'
import {PLVAbilityContexts} from './PLVAbilityContexts'

export class PLVBrightnessManager {

  // <editor-fold defaultstate="collapsed" desc="单例">

  private static readonly instance = new PLVBrightnessManager()

  private constructor() {
  }

  static getInstance() {
    return PLVBrightnessManager.instance
  }

  // </editor-fold>

  /**
   * 获取当前窗口亮度
   * @returns 手动设置范围 [0.0, 1.0]，跟随系统亮度返回 -1
   */
  async getBrightness(): Promise<number | undefined> {
    const context = PLVAbilityContexts.getInstance().lastContext()
    if (!context) {
      return undefined
    }
    const lastWindow = await window.getLastWindow(context)
    return lastWindow.getWindowProperties().brightness
  }

  /**
   * 设置当前窗口亮度
   * @param brightness 手动设置范围 [0.0, 1.0]，跟随系统亮度传 -1
   */
  async setBrightness(brightness: number): Promise<void> {
    const context = PLVAbilityContexts.getInstance().lastContext()
    if (!context) {
      return
    }
    const lastWindow = await window.getLastWindow(context)
    await lastWindow.setWindowBrightness(brightness)
  }

}