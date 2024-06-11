import mediaquery from '@ohos.mediaquery';
import { PLVOrientationManager } from './PLVOrientationManager';

@Component
export struct PLVOrientationManagerObserver {
  private readonly listener = mediaquery.matchMediaSync('(orientation: landscape)');

  aboutToAppear(): void {
    this.listener.on('change', this.onOrientationChanged)
  }

  aboutToDisappear(): void {
    this.listener.off('change', this.onOrientationChanged)
  }

  onOrientationChanged(isOrientationLandscape: mediaquery.MediaQueryResult) {
    if (isOrientationLandscape.matches) {
      PLVOrientationManager.getInstance().isPortrait.value = false;
    } else {
      PLVOrientationManager.getInstance().isPortrait.value = true;
    }
  }

  build() {
  }
}