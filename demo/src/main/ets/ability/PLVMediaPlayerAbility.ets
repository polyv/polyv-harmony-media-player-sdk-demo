import window from '@ohos.window';
import UIAbility from '@ohos.app.ability.UIAbility';
import { PLVBackgroundTaskManager, PLVOrientationManager } from 'media-player-common';
import AbilityConstant from '@ohos.app.ability.AbilityConstant';
import Want from '@ohos.app.ability.Want';

export class PLVMediaPlayerAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    PLVBackgroundTaskManager.getInstance().setupContext(this.context)
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.getMainWindow().then((window) => {
      this.observeOrientation(window)
      // 禁止录屏、截图
      // window.setWindowPrivacyMode(true)
    })
    windowStage.loadContent('pages/PLVMediaPlayerEntrancePage');
  }

  onDestroy(): void | Promise<void> {
    PLVBackgroundTaskManager.getInstance().destroy()
  }

  private observeOrientation(window: window.Window) {
    PLVOrientationManager.getInstance().isPortrait.observe((isPortrait) => {
      window.setWindowLayoutFullScreen(!isPortrait)
      window.setWindowSystemBarEnable(isPortrait ? ['status', 'navigation'] : [])
    })
  }
}
