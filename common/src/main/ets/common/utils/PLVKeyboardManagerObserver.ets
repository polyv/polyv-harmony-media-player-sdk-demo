import { window } from '@kit.ArkUI';
import { px, vp } from './PLVDisplayUtils';
import { PLVKeyboardManager } from './PLVKeyboardManager';

@Component
export struct PLVKeyboardManagerObserver {
  aboutToAppear(): void {
    const context = this.getUIContext().getHostContext()
    window.getLastWindow(context)
      .then(windowInstance => {
        windowInstance.on('keyboardHeightChange', this.onKeyboardHeightChange)
      })
  }

  build() {

  }

  private readonly onKeyboardHeightChange = (height: number) => {
    PLVKeyboardManager.getInstance().keyboardHeight.setValue(vp(px(height).vp))
  }

  aboutToDisappear(): void {
    const context = this.getUIContext().getHostContext()
    window.getLastWindow(context)
      .then(windowInstance => {
        windowInstance.off('keyboardHeightChange', this.onKeyboardHeightChange)
      })
  }
}