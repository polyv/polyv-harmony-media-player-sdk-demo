import { MutableObserver } from '@polyvharmony/media-player-sdk'
import {
  isPortrait,
  PLVMediaPlayerBitRateSelectLayoutLand,
  PLVMediaPlayerMoreLayoutLand,
  PLVMediaPlayerMoreLayoutPort,
  PLVMediaPlayerMoreSubtitleSettingLayoutLand,
  PLVMediaPlayerMoreSubtitleSettingLayoutPort,
  PLVMediaPlayerSpeedSelectLayoutLand,
  PLVOrientationManager
} from 'media-player-common'

@Component
export struct PLVMediaPlayerSingleVideoFloatActionLayout {
  @State isPortrait: boolean = isPortrait()
  private observers: MutableObserver[] = []

  aboutToAppear(): void {
    PLVOrientationManager.getInstance().isPortrait.observe((isPortrait: boolean) => {
      this.isPortrait = isPortrait
    }).pushTo(this.observers)
  }

  build() {
    if (this.isPortrait) {
      PLVMediaPlayerMoreLayoutPort({
        showCastAction: true
      })
      PLVMediaPlayerMoreSubtitleSettingLayoutPort()
    } else {
      PLVMediaPlayerMoreLayoutLand({
        showCastAction: true
      })
      PLVMediaPlayerBitRateSelectLayoutLand()
      PLVMediaPlayerSpeedSelectLayoutLand()
      PLVMediaPlayerMoreSubtitleSettingLayoutLand()
    }
  }

  aboutToDisappear(): void {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }
}