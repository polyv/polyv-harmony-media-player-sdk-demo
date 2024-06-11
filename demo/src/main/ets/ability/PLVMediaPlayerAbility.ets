import window from '@ohos.window';
import UIAbility from '@ohos.app.ability.UIAbility';
import { PLVOrientationManager } from 'media-player-common';

export class PLVMediaPlayerAbility extends UIAbility {
  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.getMainWindow().then((window) => {
      this.observeOrientation(window)
    })
    windowStage.loadContent('pages/PLVMediaPlayerEntrancePage');
  }

  private observeOrientation(window: window.Window) {
    PLVOrientationManager.getInstance().isPortrait.observe((isPortrait) => {
      window.setWindowLayoutFullScreen(!isPortrait)
      window.setWindowSystemBarEnable(isPortrait ? ['status', 'navigation'] : [])
    })
  }
}
