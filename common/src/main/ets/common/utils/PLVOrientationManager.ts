import {MutableState} from '@polyvharmony/media-player-sdk';
import {isPortrait} from './PLVDisplayUtils';
import window from '@ohos.window';
import {PLVAbilityContexts} from './PLVAbilityContexts';

export class PLVOrientationManager {
  private static readonly instance = new PLVOrientationManager();

  private constructor() {
  }

  static getInstance(): PLVOrientationManager {
    return PLVOrientationManager.instance;
  }

  readonly isPortrait: MutableState<boolean> = new MutableState(isPortrait())

  requestOrientation(orientation: 'port' | 'land') {
    const context = PLVAbilityContexts.getInstance().lastContext()
    const windowOrientation = orientation === 'port' ? window.Orientation.PORTRAIT : window.Orientation.LANDSCAPE
    if (!context) {
      return
    }
    window.getLastWindow(context).then((lastWindow) => {
      lastWindow.setPreferredOrientation(windowOrientation)
    })
  }

}