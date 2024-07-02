import mediaquery from '@ohos.mediaquery';
import { isPortrait } from './PLVDisplayUtils';
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
    PLVOrientationManager.getInstance().isPortrait.value = isPortrait();
  }

  build() {
  }
}