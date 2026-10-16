import { MutableObserver } from '@polyvharmony/media-player-sdk'
import {
  isPortrait,
  PLVMediaPlayerBitRateSelectLayoutLand,
  PLVMediaPlayerKnowledgeLayout,
  PLVMediaPlayerMoreLayoutLand,
  PLVMediaPlayerMoreLayoutPort,
  PLVMediaPlayerMoreSubtitleSettingLayoutLand,
  PLVMediaPlayerMoreSubtitleSettingLayoutPort,
  PLVMediaPlayerRouteSelectLayout,
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
      PLVMediaPlayerRouteSelectLayout()
      PLVMediaPlayerMoreLayoutPort({
        showCastAction: true
      })
      PLVMediaPlayerMoreSubtitleSettingLayoutPort()
    } else {
      PLVMediaPlayerRouteSelectLayout()
      PLVMediaPlayerMoreLayoutLand({
        showCastAction: true
      })
      PLVMediaPlayerBitRateSelectLayoutLand()
      PLVMediaPlayerSpeedSelectLayoutLand()
      PLVMediaPlayerMoreSubtitleSettingLayoutLand()
      PLVMediaPlayerKnowledgeLayout()
    }
  }

  aboutToDisappear(): void {
    MutableObserver.disposeAll(this.observers)
    this.observers = []
  }
}
